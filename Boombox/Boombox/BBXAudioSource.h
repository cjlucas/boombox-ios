//
//  BBXAudioSource.h
//  Boombox
//
//  Created by Christopher Lucas on 6/10/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBXAudioSource

- (size_t)readData:(void *)buf ofSize:(size_t)bufSize;
- (BOOL)reachedEndOfFile;
- (void)close;

@end