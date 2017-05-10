//
//  BBXAudioQueueBufferManager.m
//  Boombox
//
//  Created by Christopher Lucas on 6/6/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXAudioQueueBufferManager.h"

#import "vbuf.h"

void bbxAudioQueueOutputCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
{
    NSLog(@"bbxAudioQueueOutputCallback");
    BBXAudioQueueBufferManager *h = (__bridge BBXAudioQueueBufferManager *)inUserData;
    [h reuseAudioBuffer:inBuffer];
}

@interface BBXAudioQueueBufferManager ()

@property AudioQueueBufferRef *buffers;
@property NSRecursiveLock *buffersLock;
@property size_t buffersCount;
@property BOOL *buffersInUse;
@property vbuf_t *dataBuf;
@property UInt32 numPackets;
@property AudioStreamPacketDescription *packetDescs;
@property size_t packetDescsCount;
@property UInt32 queueBufferCapacity;
@property NSCondition *bufferAvailableCondition;

- (AudioQueueBufferRef)getAvailableBuffer;
- (BOOL)enqueueDataOntoQueue:(AudioQueueRef)audioQueue untilExhausted:(BOOL)doUntilExhausted;

@end

@implementation BBXAudioQueueBufferManager

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        NSLog(@"HERE HH");
        _dataBuf = malloc(sizeof(vbuf_t));
        vbuf_init(_dataBuf, 1 << 16);
        _buffersLock = [[NSRecursiveLock alloc] init];
        _bufferAvailableCondition = [[NSCondition alloc] init];
    }
    
    return self;
}

- (void)allocateBuffersWithQueue:(AudioQueueRef)audioQueue numBuffers:(UInt32)numBuffers andBufferSize:(UInt32)bufferSize
{
    self.queueBufferCapacity = bufferSize;
    self.buffersCount = numBuffers;
    self.buffers = malloc(sizeof(AudioQueueBufferRef) * self.buffersCount);
    self.buffersInUse = malloc(sizeof(BOOL) * self.buffersCount);
    
    for (int i = 0; i < self.buffersCount; i++) {
        if (AudioQueueAllocateBuffer(audioQueue, bufferSize, &self.buffers[i])) {
            printf("AudioQueueAllocateBuffer error\n");
        }
        self.buffersInUse[i] = NO;
    }
}

- (BOOL)enqueueBuffer:(AudioQueueBufferRef)queueBuf toQueue:(AudioQueueRef)audioQueue
{
    if (self.numPackets > 0 && self.packetDescs[0].mDataByteSize > 0 ) { // VBR
        UInt32 numPackets = 0;
        
        for (int i = 0; i < self.numPackets; i++) {
            AudioStreamPacketDescription *desc = &self.packetDescs[i];
            
            // If packet is too large to fit in buffer...
            if (queueBuf->mAudioDataByteSize + desc->mDataByteSize > queueBuf->mAudioDataBytesCapacity) {
                break;
            }
            
            size_t bytesRead = vbuf_read(self.dataBuf, queueBuf->mAudioData + queueBuf->mAudioDataByteSize, desc->mDataByteSize);
            desc->mStartOffset = queueBuf->mAudioDataByteSize;
            queueBuf->mAudioDataByteSize += bytesRead;
            numPackets++;
        }
        
        if (numPackets == 0) {
            return NO;
        }
        
        NSLog(@"enqueued buffer of %d packets", numPackets);
        OSStatus err;
        if ((err = AudioQueueEnqueueBuffer(audioQueue, queueBuf, numPackets, self.packetDescs)) && err != 0) {
            NSLog(@"AudioQueueEnqueueBuffer error");
        }
        
        // Shift unqueued packets to front
        for (int i = 0; i + numPackets < self.numPackets; i++) {
            self.packetDescs[i] = self.packetDescs[i + numPackets];
        }
        self.numPackets -= numPackets;
        
    } else { // CBR
        queueBuf->mAudioDataByteSize = (UInt32)vbuf_read(self.dataBuf, queueBuf->mAudioData, queueBuf->mAudioDataBytesCapacity);
        printf("enqueue buffer status = %d\n", AudioQueueEnqueueBuffer(audioQueue, queueBuf, 0, NULL));
    }
    
    return YES;
}

- (BOOL)addDataToQueue:(AudioQueueRef)audioQueue bytes:(void *)bytes ofSize:(UInt32)numBytes withPacketDescriptions:(AudioStreamPacketDescription *)descs numPackets:(UInt32)numPackets;
{
    vbuf_append(self.dataBuf, bytes, numBytes);
   
    if (self.numPackets + numPackets > self.packetDescsCount) {
        size_t newSize = self.numPackets + numPackets;
        self.packetDescs = realloc(self.packetDescs, sizeof(AudioStreamPacketDescription) * newSize);
        self.packetDescsCount = newSize;
    }
   
    if (descs != NULL) {
        for (int i = 0; i < numPackets; i++) {
            self.packetDescs[self.numPackets + i] = descs[i];
        }
    }
    
    self.numPackets += numPackets;

    // Wait until we have enough data to fill an entire buffer
    if (vbuf_size(self.dataBuf) < self.queueBufferCapacity) {
        return NO;
    }
    
    AudioQueueBufferRef queueBuf = [self getAvailableBuffer];
    BOOL bufferEnqueued = [self enqueueBuffer:queueBuf toQueue:audioQueue];
    
    if (!bufferEnqueued) {
        [self reuseAudioBuffer:queueBuf];
    }
    
    return bufferEnqueued;
}

- (void)enqueueRemainingData:(AudioQueueRef)audioQueue
{
    while (vbuf_size(self.dataBuf) > 0) {
        AudioQueueBufferRef buf = [self getAvailableBuffer];
        if (![self enqueueBuffer:buf toQueue:audioQueue]) {
            [self reuseAudioBuffer:buf];
        }
    }
}

- (NSInteger)getAvailableBufferIndex
{
    [self.buffersLock lock];
    
    for (int i = 0; i < self.buffersCount; i++) {
        if (!self.buffersInUse[i]) {
            [self.buffersLock unlock];
            return i;
        }
    }
    
    [self.buffersLock unlock];
    return -1;
}

- (AudioQueueBufferRef)getAvailableBuffer
{
    [self.buffersLock lock];
    [self.bufferAvailableCondition lock];
    NSInteger bufferIndex = [self getAvailableBufferIndex];
    
    while (bufferIndex == -1) {
        [self.buffersLock unlock];
        [self.bufferAvailableCondition wait];
        [self.buffersLock lock];
        bufferIndex = [self getAvailableBufferIndex];
    }
    
    
    self.buffersInUse[bufferIndex] = YES;

    AudioQueueBufferRef buf = self.buffers[bufferIndex];
  
    [self.buffersLock unlock];
    [self.bufferAvailableCondition unlock];
    return buf;
}

- (void)flush
{
    vbuf_flush(self.dataBuf);
}

- (void)dealloc
{
    free(self.buffers);
    free(self.buffersInUse);
    vbuf_free(self.dataBuf);
    free(self.dataBuf);
}

- (void)reuseAudioBuffer:(AudioQueueBufferRef)buffer
{
    // reset stats
    buffer->mAudioDataByteSize = 0;
    [self.buffersLock lock];
    for (int i = 0; i < self.buffersCount; i++) {
        if (self.buffers[i] == buffer) {
//            NSLog(@"reusing buffer %d", i);
            self.buffersInUse[i] = NO;
            break;
        }
    }
    [self.buffersLock unlock];
    [self.bufferAvailableCondition signal];
}

@end
