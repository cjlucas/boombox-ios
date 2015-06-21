//
//  BBXPlayer.h
//  Boombox
//
//  Created by Christopher Lucas on 6/6/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BBXAudioEngine.h"
#import "BBXPlaylist.h"

@interface BBXPlayer : NSObject <BBXAudioEngineDelegate>

@property (copy) BBXPlaylist *playlist;

- (void)addURL:(NSURL *)url; // convenience
- (void)addItem:(id <BBXPlaylistItem>)item;
- (void)play;
- (void)playItem:(id <BBXPlaylistItem>)item; // item must first be added
- (void)pause;
- (void)next;
- (void)prev;
@end
