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

@protocol BBXAudioQueueManagerDelegate;

@interface BBXAudioQueueManager : NSObject <BBXAudioHandlerDelegate>

@property (weak) __nullable id <BBXAudioQueueManagerDelegate> delegate;

- (void)addAudioSource:(__nonnull id <BBXAudioSource>)audioSource;
- (void)play;
- (void)pause;
- (void)stop;
- (void)reset;

@end

@protocol BBXAudioQueueManagerDelegate

- (void)audioQueueManager:(BBXAudioQueueManager * __nonnull)manager didStartPlayingSource:(__nonnull id <BBXAudioSource>)source;
- (void)audioQueueManager:(BBXAudioQueueManager * __nonnull)manager didFinishPlayingSource:(__nonnull id <BBXAudioSource>)source;
- (void)audioQueueManagerDidStop:(BBXAudioQueueManager * __nonnull)manager;
@end