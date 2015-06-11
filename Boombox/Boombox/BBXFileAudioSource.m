//
//  BBXFileAudioSource.m
//  Boombox
//
//  Created by Christopher Lucas on 6/10/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXFileAudioSource.h"

@implementation BBXFileAudioSource {
    FILE *fp;
}

- (instancetype)initWithURL:(NSURL *)url
{
    fp = fopen(url.fileSystemRepresentation, "rb");
    if (fp == NULL) {
        return nil;
    }
    
    return self;
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
