//
//  AbsAudioHandler.m
//  TBDAudioPlayer
//
//  Created by Christopher Lucas on 6/3/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXAudioHandler.h"

@interface BBXAudioHandler (private)
@end

@implementation BBXAudioHandler

- (instancetype)init
{
    return self;
}

- (void)dispose
{
}

- (void)releaseBuffers
{
    [NSException raise:@"Not implemented" format:@""];
}

- (void)feedData:(void *)buf ofSize:(size_t)bufSize
{
    [NSException raise:@"Not implemented" format:@""];
}

@end
