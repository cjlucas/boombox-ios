//
//  BBXPlayer.m
//  Boombox
//
//  Created by Christopher Lucas on 6/6/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXPlayer.h"

#import "BBXFileAudioSource.h"
#import "BBXHTTPAudioSource.h"

@interface NSURL (BBXPlaylistItem) <BBXPlaylistItem>
@end

@implementation NSURL (BBXPlaylistItem)

- (NSURL *)url
{
    return self;
}
@end

@interface BBXPlayer ()

@property BBXAudioEngine *queueManager;

@end

@implementation BBXPlayer

- (instancetype)init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _queueManager = [[BBXAudioEngine alloc] init];
    _queueManager.delegate = self;
    _playlist = [[BBXPlaylist alloc] init];
    return self;
}

- (id <BBXAudioSource>)audioSourceForPlaylistItem:(id <BBXPlaylistItem>)item
{
    NSString *scheme = [item url].scheme;
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        return [[BBXHTTPAudioSource alloc] initWithURL:[item url]];
    } else if ([scheme isEqualToString:@"file"]) {
        return [[BBXFileAudioSource alloc] initWithURL:[item url]];
    }
    
    [NSException raise:@"BBXUnknownSchemeError" format:@"Unknown scheme: %@", scheme];
    return nil;
}

- (void)addURL:(NSURL *)url
{
    [self.playlist addItem:url];
}

- (void)addItem:(id<BBXPlaylistItem>)item
{
    [self.playlist addItem:item];
}

- (void)primeAudioQueueManager
{
    id <BBXPlaylistItem> item = [self.playlist current];
    if (item == nil) {
        return;
    }
    
    [self.queueManager queueAudioSource:[self audioSourceForPlaylistItem:item]];
    
    item = [self.playlist peekNext];
    if (item != nil) {
        [self.queueManager queueAudioSource:[self audioSourceForPlaylistItem:item]];
        
    }
}

- (void)play
{
    if (self.queueManager.currentAudioSource == nil) {
        [self primeAudioQueueManager];
    } else if (self.queueManager.audioQueueState == BBXAudioQueuePaused) {
        [self.queueManager play];
    }
}

- (void)playItem:(id<BBXPlaylistItem>)item
{
    [self.queueManager reset];
    self.playlist.currentPlaylistIndex = [self.playlist.items indexOfObject:item];
    [self primeAudioQueueManager];
}

- (void)pause
{
    [self.queueManager pause];
}

- (void)next
{
    if ([self.playlist peekNext] != nil) {
        [self.queueManager next];
        [self.playlist next];
        if ([self.playlist peekNext] != nil) {
            
        }
    }
}

- (void)prev
{
    if ([self.playlist peekPrev] != nil) {
        [self.queueManager reset];
        [self.playlist prev];
        [self primeAudioQueueManager];
    }
}

#pragma mark - BBXAudioEngineDelegate

- (void)audioEngine:(BBXAudioEngine * __nonnull)manager didStartPlayingSource:(id<BBXAudioSource> __nonnull)source
{
}

- (void)audioEngine:(BBXAudioEngine * __nonnull)manager didFinishPlayingSource:(id<BBXAudioSource> __nonnull)source
{
    NSLog(@"it finished playing!");
    [self.playlist next];
    
    id <BBXPlaylistItem> item = [self.playlist peekNext];
    if (item != nil) {
        [self.queueManager queueAudioSource:[self audioSourceForPlaylistItem:item]];
    }
}

@end
