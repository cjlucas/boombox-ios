//
//  BBXPlaylist.h
//  Boombox
//
//  Created by Christopher Lucas on 6/19/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBXPlaylistItem

- (NSURL * __nonnull)url;

@end

@interface BBXPlaylist : NSObject

@property NSUInteger currentPlaylistIndex;

- (__nullable id <BBXPlaylistItem>)current;
- (__nullable id <BBXPlaylistItem>)next;
- (__nullable id <BBXPlaylistItem>)peekNext;
- (__nullable id <BBXPlaylistItem>)prev;
- (__nullable id <BBXPlaylistItem>)peekPrev;

- (void)addItem:(__nonnull id <BBXPlaylistItem>)item;
- (NSArray * __nonnull)items; // of id <BBXPlaylistItem>

@end
