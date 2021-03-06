//
//  Boombox.h
//  Boombox
//
//  Created by Christopher Lucas on 6/6/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

//! Project version number for Boombox.

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double BoomboxVersionNumber;

//! Project version string for Boombox.
FOUNDATION_EXPORT const unsigned char BoomboxVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Boombox/PublicHeader.h>


#import "BBXAudioHandler.h"
#import "BBXAudioFileStreamHandler.h"
#import "BBXAudioQueueBufferManager.h"
#import "BBXAudioEngine.h"
#import "BBXFileAudioSource.h"
#import "BBXPlayer.h"
#import "BBXPlaylist.h"
#import "BBXHTTPAudioSource.h"