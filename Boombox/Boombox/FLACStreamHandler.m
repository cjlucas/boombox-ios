//
//  FLACStreamHandler.m
//  TBDAudioPlayer
//
//  Created by Christopher Lucas on 6/4/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "FLACStreamHandler.h"
#import <pthread.h>

FLAC__StreamDecoderReadStatus flacStreamDecoderReadCallback(const FLAC__StreamDecoder *decoder, FLAC__byte buffer[], size_t *size, void *clientData) {
    FLACStreamHandler *h = (__bridge FLACStreamHandler *)clientData;
    pthread_mutex_lock(&h->flacBufferLock);
    if (vbuf_size(&h->flacBuffer) > 0) {
        *size = vbuf_read(&h->flacBuffer, buffer, *size);
        h->bytesDecoded += *size;
        printf("bytesDecoded: %zu\n", h->bytesDecoded);
    } else {
        *size = 0;
    }
    pthread_mutex_unlock(&h->flacBufferLock);
   
    return h->bytesRead == h->bytesDecoded ? FLAC__STREAM_DECODER_READ_STATUS_CONTINUE : FLAC__STREAM_DECODER_READ_STATUS_CONTINUE;
}

FLAC__StreamDecoderWriteStatus flacStreamDecoderWriteCallback(const FLAC__StreamDecoder *decoder, const FLAC__Frame *frame, const FLAC__int32 *const buffer[], void *clientData) {
    printf("writeCB\n");
    FLACStreamHandler *h = (__bridge FLACStreamHandler *)clientData;
   
    for (int i = 0; i < frame->header.blocksize; i++) {
        for (int j = 0; j < frame->header.channels; j++) {
            vbuf_append(&h->pcmBuffer, (void *)&buffer[j][i], 2); // 2 == 16 bpp
        }
    }

    if (vbuf_size(&h->pcmBuffer) > AUDIO_BUFFER_SIZE) {
        AudioQueueBufferRef queueBuffer = [h getBuffer];
        if (queueBuffer == nil) {
            printf("queuebuffer is null\n");
            return FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
        }
        queueBuffer->mAudioDataByteSize = (UInt32)vbuf_read(&h->pcmBuffer, queueBuffer->mAudioData, AUDIO_BUFFER_SIZE);
        [h.delegate onAvailableBuffer:queueBuffer numPacketDescs:0 packetDescs:NULL];
    }
    return FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
}

void flacStreamDecoderErrorCallback(const FLAC__StreamDecoder *decoder, FLAC__StreamDecoderErrorStatus status, void *client_data) {
    printf("flac error cb %d\n", status);
}

@implementation FLACStreamHandler

- (instancetype)init
{
    if ((self = [super init]) && self != nil) {
        vbuf_init(&flacBuffer, 0);
        vbuf_init(&pcmBuffer, 0);
        
        decoder = FLAC__stream_decoder_new();
        FLAC__stream_decoder_init_stream(decoder, flacStreamDecoderReadCallback, NULL, NULL, NULL, NULL, flacStreamDecoderWriteCallback, NULL, flacStreamDecoderErrorCallback, (__bridge void *)self);
        
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(q, ^{
            FLAC__stream_decoder_process_until_end_of_stream(decoder);
            printf("doneeee\n");
            while (vbuf_size(&pcmBuffer) > 0) {
                AudioQueueBufferRef queueBuffer = [self getBuffer];
                if (queueBuffer == nil) {
                    printf("queuebuffer is null\n");
                    sleep(1);
                    continue;
                }
                queueBuffer->mAudioDataByteSize = (UInt32)vbuf_read(&pcmBuffer, queueBuffer->mAudioData, AUDIO_BUFFER_SIZE);
                [self.delegate onAvailableBuffer:queueBuffer numPacketDescs:0 packetDescs:NULL];
                
            }
        });

    }
    
    return self;
}

- (void)feedData:(void *)buf ofSize:(size_t)bufSize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    AudioStreamBasicDescription asbd2 = {
        .mFormatID = kAudioFormatLinearPCM,
        .mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
        .mSampleRate = 44100,
        .mChannelsPerFrame = 2,
        .mBitsPerChannel = 16,
        .mBytesPerPacket = 4,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 4,
        .mReserved = 0
    };
    
 
    [self.delegate onBasicDescriptionAvailable:asbd2];
    });
    
    bytesRead += bufSize;
    
    pthread_mutex_lock(&flacBufferLock);
    vbuf_append(&flacBuffer, buf, bufSize);
    pthread_mutex_unlock(&flacBufferLock);
}

@end
