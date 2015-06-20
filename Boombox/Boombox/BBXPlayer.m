//
//  BBXPlayer.m
//  Boombox
//
//  Created by Christopher Lucas on 6/6/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXPlayer.h"

#import "BBXFileAudioSource.h"

@interface BBXPlayer ()

@property BBXAudioQueueManager *queueManager;

@end

@implementation BBXPlayer

- (instancetype)init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _queueManager = [[BBXAudioQueueManager alloc] init];
    return self;
}

- (void)addURL:(NSURL *)url
{
    BBXFileAudioSource *src = [[BBXFileAudioSource alloc] initWithURL:url];
    [self.queueManager addAudioSource:src];
}

- (void)play
{
    [self.queueManager play];
}

- (void)pause
{
    [self.queueManager pause];
}

- (void)next
{
    [self.queueManager reset];
}

#pragma mark - BBXAudioQueueManagerDelegate

- (void)audioQueueManager:(BBXAudioQueueManager * __nonnull)manager didStartPlayingSource:(id<BBXAudioSource> __nonnull)source
{
    
}

- (void)audioQueueManager:(BBXAudioQueueManager * __nonnull)manager didFinishPlayingSource:(id<BBXAudioSource> __nonnull)source
{
    
}

- (void)audioQueueManagerDidStop:(BBXAudioQueueManager * __nonnull)manager
{
    
}

@end
