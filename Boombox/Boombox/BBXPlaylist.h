//
//  BBXPlaylist.h
//  Boombox
//
//  Created by Christopher Lucas on 6/19/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBXPlaylistItem

- (NSURL *)url;

@end

@interface BBXPlaylist : NSObject

- (id <BBXPlaylistItem>)current;
- (id <BBXPlaylistItem>)next;
- (id <BBXPlaylistItem>)peekNext;
- (id <BBXPlaylistItem>)prev;
- (id <BBXPlaylistItem>)peekPrev;

- (void)addItem:(id <BBXPlaylistItem>)entry;
- (NSArray *)playlist; // of id <BBXPlaylistItem>

@end
