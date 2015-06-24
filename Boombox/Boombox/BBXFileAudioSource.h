//
//  BBXFileAudioSource.h
//  Boombox
//
//  Created by Christopher Lucas on 6/10/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BBXAudioSource.h"

@interface BBXFileAudioSource : NSObject <BBXURLAudioSource>

- (instancetype)initWithURL:(NSURL *)url;

@end
