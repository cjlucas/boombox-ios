//
//  BBXFileAudioSource.h
//  Boombox
//
//  Created by Christopher Lucas on 6/10/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BBXAudioSource.h"

@interface BBXFileAudioSource : NSObject <BBXAudioSource>

- (instancetype)initWithURL:(NSURL *)url;

@end
