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

@interface BBXAudioQueueManager : NSObject <BBXAudioHandlerDelegate>

- (void)addAudioSource:(id <BBXAudioSource>)audioSource;
- (void)doit;

@end
