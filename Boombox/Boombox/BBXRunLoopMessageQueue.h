//
//  BBXRunLoopMessageQueue.h
//  Boombox
//
//  Created by Christopher Lucas on 6/6/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BBXRunLoopMessage) {
    BBXNoMessage,
    BBXPlaying,
    BBXPaused,
    BBXPlayRequested,
    BBXPauseRequested,
    BBXStopRequested,
    BBXResetRequested,
    BBXAudioSourceAvailable,
    BBXReachedEndOfAudioSource,
};

@interface BBXRunLoopMessageQueue : NSObject {
    @private
    NSMutableArray *messages;
    NSLock *messagesLock;
}

- (void)push:(BBXRunLoopMessage)message;
- (BBXRunLoopMessage)pull;

@end
