//
//  FLACStreamHandler.h
//  TBDAudioPlayer
//
//  Created by Christopher Lucas on 6/4/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <FLACiOS/all.h>

#import "AbsAudioHandler.h"
#import "GrowableBuffer.h"

@interface FLACStreamHandler : AbsAudioHandler {
    @public
    FLAC__StreamDecoder *decoder;
    vbuf_t flacBuffer;
    vbuf_t pcmBuffer;
    pthread_mutex_t flacBufferLock;
    size_t bytesDecoded;
    size_t bytesRead;
}

@end
