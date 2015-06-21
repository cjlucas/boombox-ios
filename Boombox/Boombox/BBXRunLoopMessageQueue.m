//
//  BBXRunLoopMessageQueue.m
//  Boombox
//
//  Created by Christopher Lucas on 6/6/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXRunLoopMessageQueue.h"

@implementation BBXRunLoopMessageQueue

- (instancetype)init
{
    self = [super init];
    messages = [[NSMutableArray alloc] init];
    messagesLock = [[NSLock alloc] init];
    
    return self;
}

- (void)push:(BBXRunLoopMessage)message
{
    [messagesLock lock];
    [messages insertObject:[NSNumber numberWithInteger:message] atIndex:0];
    [messagesLock unlock];
    
}

- (BBXRunLoopMessage)pull
{
    BBXRunLoopMessage msg = BBXNoMessage;
   
    [messagesLock lock];
    if (messages.count > 0) {
        NSNumber *n = [messages lastObject];
        [messages removeLastObject];
        msg = (BBXRunLoopMessage)[n integerValue];
    }
    [messagesLock unlock];
    
    return msg;
}

@end
