//
//  BBXPlayer.m
//  Boombox
//
//  Created by Christopher Lucas on 6/6/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXPlayer.h"

#import "BBXAudioHandler.h"
#import "BBXRunLoopMessageQueue.h"

@implementation BBXPlayer {
    BBXAudioHandler *currentHandler;
    BBXRunLoopMessageQueue *msgQueue;
    NSThread *thread;
}

- (instancetype)init
{
    msgQueue = [[BBXRunLoopMessageQueue alloc] init];
    return self;
}

- (BOOL)start
{
    if (thread == nil) {
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(runForever:) object:nil];
        [thread start];
        return thread.executing;
    } else {
        return NO;
    }
}

- (void)runForever:(id)thing
{
    while (true) {
        printf("rawr");
        switch ([msgQueue pull]) {
            case BBXPlayRequested:
                break;
            case BBXPauseRequested:
                break;
            case BBXNoMessage:
                break;
        }
        usleep(100000);
    }
}

@end
