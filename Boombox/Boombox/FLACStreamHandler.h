//
//  FLACStreamHandler.h
//  TBDAudioPlayer
//
//  Created by Christopher Lucas on 6/4/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <FLAC/all.h>

#import "vbuf.h"

#import "BBXAudioHandler.h"

@interface FLACStreamHandler : NSObject <BBXAudioHandler> {
    @public
    FLAC__StreamDecoder *decoder;
    vbuf_t flacBuffer;
    pthread_mutex_t flacBufferLock;
    size_t bytesDecoded;
    size_t bytesRead;
}

@property (weak) id <BBXAudioHandlerDelegate> delegate;

@end
