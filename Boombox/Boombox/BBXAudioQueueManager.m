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

typedef NS_ENUM(NSInteger, BBXAudioQueueState) {
    BBXAudioQueueInitialized,
    BBXAudioQueueStarted,
    BBXAudioQueuePaused,
};

@interface BBXAudioQueueManager ()

@property BBXAudioQueueBufferHandler *queueBufferHandler;
@property id <BBXAudioHandler> currentHandler;
@property id <BBXAudioSource> currentAudioSource;
@property id <BBXAudioHandler> nextHandler;
@property id <BBXAudioSource> nextAudioSource;
@property NSMutableArray *audioSources; // id <BBXAudioSource>
@property NSLock *audioSourcesLock;
@property BBXRunLoopMessageQueue *messageQueue;
@property BBXAudioQueueState audioQueueState;

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
    _messageQueue = [[BBXRunLoopMessageQueue alloc] init];

    // start internal run loop
    NSThread *r = [[NSThread alloc] initWithTarget:self selector:@selector(loop:) object:nil];
    [r start];
    
    return self;
}

#pragma mark - BBXAudioHandlerDelegate methods

- (void)onAvailableData:(id <BBXAudioHandler>)handler data:(void *)bytes numBytes:(UInt32)numBytes numPacketDescs:(UInt32)numPacketDescs packetDescs:(AudioStreamPacketDescription *)packetDescs
{
    if ([self.queueBufferHandler addDataToQueue:queues[0] bytes:bytes ofSize:numBytes withPacketDescriptions:packetDescs numPackets:numPacketDescs] && self.audioQueueState == BBXAudioQueueInitialized) {
        AudioQueueStart(queues[0], NULL);
        self.audioQueueState = BBXAudioQueueStarted;
        [self.delegate audioQueueManager:self didStartPlayingSource:self.currentAudioSource];
    }
}

- (void)onBasicDescriptionAvailable:(id <BBXAudioHandler>)handler audioDescription:(AudioStreamBasicDescription)desc
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.queueBufferHandler = [[BBXAudioQueueBufferHandler alloc] init];
        
        if (AudioQueueNewOutput(&desc, bbxAudioQueueOutputCallback, (__bridge void *)self.queueBufferHandler, NULL, 0, 0, &queues[0])) {
            NSLog(@"failed to create new audio queue");
            return;
        }
       
        self.audioQueueState = BBXAudioQueueInitialized;
        [self.queueBufferHandler allocateBuffersWithQueue:queues[0] numBuffers:1 << 2 andBufferSize:1 << 14];
    });
}

#pragma mark -

- (void)addAudioSource:(id<BBXAudioSource>)audioSource
{
    [self.audioSourcesLock lock];
    [self.audioSources addObject:audioSource];
    [self.audioSourcesLock unlock];
    [self.messageQueue push:BBXAudioSourceAvailable];
}

- (void)primeAudioSourceHandlers
{
    [self.audioSourcesLock lock];
    
    if (self.audioSources.count == 0) {
        return;
    }
    
    if (self.currentAudioSource == nil) {
        self.currentAudioSource = [self.audioSources objectAtIndex:0];
        [self.audioSources removeObjectAtIndex:0];
        
        
        self.currentHandler = [[BBXAudioFileStreamHandler alloc] initWithDelegate:self];
    }
    
    if (self.audioSources.count > 0 && self.nextAudioSource == nil) {
        self.nextAudioSource = [self.audioSources objectAtIndex:0];
        [self.audioSources removeObjectAtIndex:0];
        
        self.nextHandler = [[BBXAudioFileStreamHandler alloc] initWithDelegate:self];
    }

    [self.audioSourcesLock unlock];
}

- (void)handleAudioSourceAvailable
{
    [self primeAudioSourceHandlers];
    
}

- (void)handleReachedEndOfAudioSource
{
    NSLog(@"reached end of audiosource");
    [self.currentAudioSource close];
    [self.currentHandler dispose];
    
    [self.delegate audioQueueManager:self didFinishPlayingSource:self.currentAudioSource];
    self.currentAudioSource = self.nextAudioSource;
    self.currentHandler = self.nextHandler;
    
    if (self.currentAudioSource != nil) {
        [self.delegate audioQueueManager:self didStartPlayingSource:self.currentAudioSource];
    }
    
    [self primeAudioSourceHandlers];
}

- (void)fillHandler
{
    // Don't pull data from source if we're paused. this is because the audio queue buffers will eventually fill, causing BBXAudioQueueBufferHandler's addDataToQueue:... to block
    if (self.audioQueueState == BBXAudioQueuePaused) {
        return;
    }
    size_t bytesRead = [self.currentAudioSource readData:audioSourceBuf ofSize:audioSourceBufSize];
    [self.currentHandler feedData:audioSourceBuf ofSize:bytesRead];
    
    if ([self.currentAudioSource reachedEndOfFile]) {
        [self.messageQueue push:BBXReachedEndOfAudioSource];
    }
}

- (void)loop:(id)anything
{
    while (YES) {
        switch ([self.messageQueue pull]) {
            case BBXPlayRequested:
                AudioQueueStart(queues[0], NULL);
                self.audioQueueState = BBXAudioQueueStarted;
                break;
            case BBXPauseRequested:
                AudioQueuePause(queues[0]);
                self.audioQueueState = BBXAudioQueuePaused;
                break;
            case BBXStopRequested:
                AudioQueueStop(queues[0], YES);
                self.audioQueueState = BBXAudioQueueInitialized;
                [self.delegate audioQueueManagerDidStop:self];
                break;
            case BBXResetRequested:
                AudioQueueStop(queues[0], YES);
                self.audioQueueState = BBXAudioQueueInitialized;
                [self.audioSources removeAllObjects];
                
                self.currentAudioSource = nil;
                self.nextAudioSource = nil;
                
                [self.currentHandler dispose];
                [self.nextHandler dispose];
                self.currentHandler = nil;
                self.nextHandler = nil;
                break;
            case BBXAudioSourceAvailable:
                [self handleAudioSourceAvailable];
                break;
            case BBXReachedEndOfAudioSource:
                [self handleReachedEndOfAudioSource];
                break;
            default:
                [self fillHandler];
                break;
        }
    }
}


- (void)play
{
    [self.messageQueue push:BBXPlayRequested];
}


- (void)pause
{
    [self.messageQueue push:BBXPauseRequested];
}

- (void)stop
{
    [self.messageQueue push:BBXStopRequested];
}

- (void)reset
{
    [self.messageQueue push:BBXResetRequested];
}

@end
