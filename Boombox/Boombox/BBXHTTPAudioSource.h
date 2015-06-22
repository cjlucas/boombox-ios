//
//  BBXHTTPAudioSource.h
//  Boombox
//
//  Created by Christopher Lucas on 6/21/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BBXAudioSource.h"

@interface BBXHTTPAudioSource : NSObject <BBXAudioSource>

- (instancetype)initWithURL:(NSURL *)url;

@end
