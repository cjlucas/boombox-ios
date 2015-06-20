//
//  BBXPlayer.h
//  Boombox
//
//  Created by Christopher Lucas on 6/6/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BBXAudioQueueManager.h"

@interface BBXPlayer : NSObject <BBXAudioQueueManagerDelegate>

- (void)addURL:(NSURL *)url;
- (void)play;
- (void)pause;
- (void)next;
@end
