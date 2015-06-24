//
//  BBXFileAudioSource.m
//  Boombox
//
//  Created by Christopher Lucas on 6/10/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXFileAudioSource.h"

@implementation BBXFileAudioSource {
    NSURL *_url;
    FILE *fp;
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _url = url;
    return self;
}

- (void)prepare
{
    fp = fopen(_url.fileSystemRepresentation, "rb");
}

- (size_t)readData:(void *)buf ofSize:(size_t)bufSize
{
    return fread(buf, 1, bufSize, fp);
}

- (BOOL)reachedEndOfFile
{
    return feof(fp);
}

- (void)close
{
    fclose(fp);
    fp = NULL;
}

@end
