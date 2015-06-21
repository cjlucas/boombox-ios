//
//  BBXAudioEngine.h
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

@protocol BBXAudioEngineDelegate;

@interface BBXAudioEngine : NSObject <BBXAudioHandlerDelegate>

@property (readonly) __nullable id <BBXAudioSource> currentAudioSource;
@property (readonly) BBXAudioQueueState audioQueueState;
@property (weak) __nullable id <BBXAudioEngineDelegate> delegate;

- (void)queueAudioSource:(__nonnull id<BBXAudioSource>)source;
- (void)play;
- (void)pause;
- (void)reset;
- (void)next;

@end

@protocol BBXAudioEngineDelegate

- (void)audioEngine:(BBXAudioEngine * __nonnull)engine didStartPlayingSource:(__nonnull id <BBXAudioSource>)source;
- (void)audioEngine:(BBXAudioEngine * __nonnull)engine didFinishPlayingSource:(__nonnull id <BBXAudioSource>)source;
@end
