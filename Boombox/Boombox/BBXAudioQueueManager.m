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
#import "BBXRunLoopMessageQueue.h"

#define MAX_QUEUES 2

@interface BBXAudioQueueManager ()

@property BBXAudioQueueBufferHandler *queueBufferHandler;
@property id <BBXAudioHandler> audioHandler;
@property BBXRunLoopMessageQueue *messageQueue;
@property NSMutableArray *queuedSources;
@property NSLock *queuedSourcesLock;

@end

@implementation BBXAudioQueueManager {
    AudioQueueRef audioQueue;
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
    _messageQueue = [[BBXRunLoopMessageQueue alloc] init];
    _queuedSources = [[NSMutableArray alloc] init];
    _queuedSourcesLock = [[NSLock alloc] init];

    // start internal run loop
    NSThread *r = [[NSThread alloc] initWithTarget:self selector:@selector(loop:) object:nil];
    [r start];
    
    return self;
}

#pragma mark - BBXAudioHandlerDelegate methods

- (void)onAvailableData:(id <BBXAudioHandler>)handler data:(void *)bytes numBytes:(UInt32)numBytes numPacketDescs:(UInt32)numPacketDescs packetDescs:(AudioStreamPacketDescription *)packetDescs
{
    if ([self.queueBufferHandler addDataToQueue:audioQueue bytes:bytes ofSize:numBytes withPacketDescriptions:packetDescs numPackets:numPacketDescs] && self.audioQueueState == BBXAudioQueueInitialized) {
        AudioQueueStart(audioQueue, NULL);
        _audioQueueState = BBXAudioQueueStarted;
        [self.delegate audioQueueManager:self didStartPlayingSource:self.currentAudioSource];
    }
}

- (void)onBasicDescriptionAvailable:(id <BBXAudioHandler>)handler audioDescription:(AudioStreamBasicDescription)desc
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.queueBufferHandler = [[BBXAudioQueueBufferHandler alloc] init];
        
        if (AudioQueueNewOutput(&desc, bbxAudioQueueOutputCallback, (__bridge void *)self.queueBufferHandler, NULL, 0, 0, &audioQueue)) {
            NSLog(@"failed to create new audio queue");
            return;
        }
       
        _audioQueueState = BBXAudioQueueInitialized;
        [self.queueBufferHandler allocateBuffersWithQueue:audioQueue numBuffers:1 << 2 andBufferSize:1 << 14];
    });
}

#pragma mark -

- (void)queueAudioSource:(id<BBXAudioSource> __nonnull)source
{
    [self.queuedSourcesLock lock];
    [self.queuedSources addObject:source];
    [self.queuedSourcesLock unlock];
    [self.messageQueue push:BBXAudioSourceQueued];
}

- (void)startNextAudioSourceInQueue
{
    [self.queuedSourcesLock lock];
    if (self.queuedSources.count == 0) {
        _currentAudioSource = nil;
    } else {
        _currentAudioSource = [self.queuedSources objectAtIndex:0];
        [self.queuedSources removeObjectAtIndex:0];
        self.audioHandler = [[BBXAudioFileStreamHandler alloc] initWithDelegate:self];
        [self.delegate audioQueueManager:self didStartPlayingSource:self.currentAudioSource];
    }
    
    [self.queuedSourcesLock unlock];
}

- (void)handleReachedEndOfAudioSource
{
    NSLog(@"reached end of audiosource");
    [self.currentAudioSource close];
    [self.audioHandler dispose];
    

    [self startNextAudioSourceInQueue];
}

- (void)fillHandler
{
    // Don't pull data from source if we're paused. this is because the audio queue buffers will eventually fill, causing BBXAudioQueueBufferHandler's addDataToQueue:... to block
    if (self.audioQueueState == BBXAudioQueuePaused) {
        return;
    }
    
    size_t bytesRead = [self.currentAudioSource readData:audioSourceBuf ofSize:audioSourceBufSize];
    if (bytesRead > 0) {
        [self.audioHandler feedData:audioSourceBuf ofSize:bytesRead];
    }
    
    if ([self.currentAudioSource reachedEndOfFile]) {
        [self.queueBufferHandler enqueueRemainingData:audioQueue];
        [self.messageQueue push:BBXReachedEndOfAudioSource];
    }
}

- (void)loop:(id)anything
{
    while (YES) {
        switch ([self.messageQueue pull]) {
            case BBXPlayRequested:
                AudioQueueStart(audioQueue, NULL);
                _audioQueueState = BBXAudioQueueStarted;
                break;
            case BBXPauseRequested:
                AudioQueuePause(audioQueue);
                _audioQueueState = BBXAudioQueuePaused;
                break;
            case BBXResetRequested:
                AudioQueueStop(audioQueue, YES);
                _audioQueueState = BBXAudioQueueInitialized;
                
                _currentAudioSource = nil;
                
                [self.audioHandler dispose];
                self.audioHandler = nil;
                [self.queueBufferHandler flush];
                break;
            case BBXAudioSourceQueued:
                if (self.currentAudioSource == nil) {
                    [self startNextAudioSourceInQueue];
                }
                break;
            case BBXReachedEndOfAudioSource:
                [self.delegate audioQueueManager:self didFinishPlayingSource:self.currentAudioSource];
                [self handleReachedEndOfAudioSource];
                break;
            case BBXNextRequested:
                AudioQueueStop(audioQueue, YES);
                _audioQueueState = BBXAudioQueueInitialized;
                [self handleReachedEndOfAudioSource];
                break;
            default:
                if (self.currentAudioSource == nil || self.audioQueueState == BBXAudioQueuePaused) {
                    usleep(50000);
                    continue;
                }
                [self fillHandler];
                break;
        }
    }
}


- (void)play
{
    if (self.audioQueueState == BBXAudioQueuePaused) {
        [self.messageQueue push:BBXPlayRequested];
    }
}


- (void)pause
{
    if (self.audioQueueState == BBXAudioQueueStarted) {
        [self.messageQueue push:BBXPauseRequested];
    }
}

- (void)stop
{
    [self.messageQueue push:BBXStopRequested];
}

- (void)reset
{
    [self.queuedSourcesLock lock];
    [self.queuedSources removeAllObjects];
    [self.queuedSourcesLock unlock];
    [self.messageQueue push:BBXResetRequested];
}

- (void)next
{
    [self.messageQueue push:BBXNextRequested];
}

@end
