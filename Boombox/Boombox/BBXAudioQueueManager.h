//
//  BBXAudioQueueManager.h
//  Boombox
//
//  Created by Christopher Lucas on 6/10/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>

#import "BBXAudioSource.h"
#import "BBXAudioHandler.h"

typedef NS_ENUM(NSInteger, BBXAudioQueueState) {
    BBXAudioQueueInitialized,
    BBXAudioQueueStarted,
    BBXAudioQueuePaused,
};

@protocol BBXAudioQueueManagerDelegate;

@interface BBXAudioQueueManager : NSObject <BBXAudioHandlerDelegate>

@property (readonly) __nullable id <BBXAudioSource> currentAudioSource;
@property (readonly) BBXAudioQueueState audioQueueState;
@property (weak) __nullable id <BBXAudioQueueManagerDelegate> delegate;

- (void)queueAudioSource:(__nonnull id<BBXAudioSource>)source;
- (void)play;
- (void)pause;
- (void)reset;
- (void)next;

@end

@protocol BBXAudioQueueManagerDelegate

- (void)audioQueueManager:(BBXAudioQueueManager * __nonnull)manager didStartPlayingSource:(__nonnull id <BBXAudioSource>)source;
- (void)audioQueueManager:(BBXAudioQueueManager * __nonnull)manager didFinishPlayingSource:(__nonnull id <BBXAudioSource>)source;
@end