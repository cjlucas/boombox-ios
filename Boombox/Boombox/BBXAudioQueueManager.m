//
//  BBXAudioQueueManager.m
//  Boombox
//
//  Created by Christopher Lucas on 6/10/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXAudioQueueManager.h"

#import "BBXAudioFileStreamHandler.h"
#import "BBXAudioQueueBufferHandler.h"

#define MAX_QUEUES 2

@interface BBXAudioQueueManager ()

@property BBXAudioQueueBufferHandler *queueBufferHandler;
@property BBXAudioHandler *currentHandler;
@property BBXAudioHandler *nextHandler;
@property NSMutableArray *audioSources; // id <BBXAudioSource>
@property NSLock *audioSourcesLock;

@end

@implementation BBXAudioQueueManager {
    AudioQueueRef queues[MAX_QUEUES];
    void *audioSourceBuf;
    size_t audioSourceBufSize;
}

- (instancetype)init
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    audioSourceBuf = malloc(1 << 14);
    audioSourceBufSize = 1 << 14;
    _audioSources = [[NSMutableArray alloc] init];
    
    return self;
}

#pragma mark - BBXAudioHandlerDelegate methods

- (void)onAvailableData:(BBXAudioHandler *)handler data:(void *)bytes numBytes:(UInt32)numBytes numPacketDescs:(UInt32)numPacketDescs packetDescs:(AudioStreamPacketDescription *)packetDescs
{
    if ([self.queueBufferHandler addDataToQueue:queues[0] bytes:bytes ofSize:numBytes withPacketDescriptions:packetDescs numPackets:numPacketDescs]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            AudioQueueStart(queues[0], NULL);
        });
    }
}

- (void)onBasicDescriptionAvailable:(BBXAudioHandler *)handler audioDescription:(AudioStreamBasicDescription)desc
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.queueBufferHandler = [[BBXAudioQueueBufferHandler alloc] init];
        
        if (AudioQueueNewOutput(&desc, bbxAudioQueueOutputCallback, (__bridge void *)self.queueBufferHandler, NULL, 0, 0, &queues[0])) {
            NSLog(@"failed to create new audio queue");
            return;
        }
        
        [self.queueBufferHandler allocateBuffersWithQueue:queues[0] numBuffers:1 << 2 andBufferSize:1 << 14];
    });
    
}

#pragma mark -

- (void)addAudioSource:(id<BBXAudioSource>)audioSource
{
    [self.audioSourcesLock lock];
    [self.audioSources addObject:audioSource];
    [self.audioSourcesLock unlock];
}

- (void)doit
{
    printf("%lu\n", (unsigned long)self.audioSources.count);
    while (self.audioSources.count == 0) {
        usleep(100000);
    }
    
    while (self.audioSources.count > 0) {
        
        [self.audioSourcesLock lock];
        
        id <BBXAudioSource> audioSource = [self.audioSources objectAtIndex:0];
        [self.audioSources removeObjectAtIndex:0];
        
        [self.audioSourcesLock unlock];
        
        self.currentHandler = [[BBXAudioFileStreamHandler alloc] init];
        self.currentHandler.delegate = self;
        
        while (![audioSource reachedEndOfFile]) {
            size_t bytesRead = [audioSource readData:audioSourceBuf ofSize:audioSourceBufSize];
            [self.currentHandler feedData:audioSourceBuf ofSize:bytesRead];
        }
    }
    
}

@end
