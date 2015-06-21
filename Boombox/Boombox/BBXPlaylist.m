//
//  BBXPlaylist.m
//  Boombox
//
//  Created by Christopher Lucas on 6/19/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXPlaylist.h"

@interface BBXPlaylist ()

@property NSMutableArray *playlist;

@end

@implementation BBXPlaylist

- (instancetype)init
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    _currentPlaylistIndex = 0;
    _playlist = [[NSMutableArray alloc] init];
    return self;
}

- (id <BBXPlaylistItem>)current
{
    if (self.currentPlaylistIndex >= self.playlist.count) {
        return nil;
    }
    
    return [self.playlist objectAtIndex:self.currentPlaylistIndex];
}

- (id <BBXPlaylistItem>)next
{
    self.currentPlaylistIndex++;
    return [self current];
}

- (id <BBXPlaylistItem>)prev

{
    self.currentPlaylistIndex--;
    return [self current];
}

- (id <BBXPlaylistItem>)peekNext
{
    if (self.currentPlaylistIndex + 1 >= self.playlist.count) {
        return nil;
    }
    
    return [self.playlist objectAtIndex:self.currentPlaylistIndex+1];
}

- (id <BBXPlaylistItem>)peekPrev
{
    if (self.currentPlaylistIndex - 1 >= self.playlist.count) {
        return nil;
    }
    
    return [self.playlist objectAtIndex:self.currentPlaylistIndex-1];
}

- (void)addItem:(id<BBXPlaylistItem> __nonnull)item
{
    [self.playlist addObject:item];
}

- (NSArray *)items
{
    return [self.playlist copy];
}

@end
