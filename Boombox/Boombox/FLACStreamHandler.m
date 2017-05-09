//
//  FLACStreamHandler.m
//  TBDAudioPlayer
//
//  Created by Christopher Lucas on 6/4/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "FLACStreamHandler.h"
#import <pthread.h>

#define AUDIO_BUFFER_SIZE (1 << 13)

FLAC__StreamDecoderReadStatus flacStreamDecoderReadCallback(const FLAC__StreamDecoder *decoder, FLAC__byte buffer[], size_t *size, void *clientData) {
    FLACStreamHandler *h = (__bridge FLACStreamHandler *)clientData;
    pthread_mutex_lock(&h->flacBufferLock);
    
    size_t sz = vbuf_size(&h->flacBuffer);
    if (sz > 0 && *size > 0) {
        if (*size > sz) {
            *size = sz;
        }
        
        *size = vbuf_read(&h->flacBuffer, buffer, *size);
        h->bytesDecoded += *size;
        printf("bytesDecoded: %zu\n", h->bytesDecoded);
    } else {
        *size = 0;
    }
    
    pthread_mutex_unlock(&h->flacBufferLock);
    
    printf("readCB: %lu bytes\n", *size);
    //sleep(1);
   
    return FLAC__STREAM_DECODER_READ_STATUS_CONTINUE;
}

FLAC__StreamDecoderWriteStatus flacStreamDecoderWriteCallback(const FLAC__StreamDecoder *decoder, const FLAC__Frame *frame, const FLAC__int32 *const buffer[], void *clientData) {
    FLACStreamHandler *h = (__bridge FLACStreamHandler *)clientData;
    printf("writeCB %s\n", FLAC__StreamDecoderStateString[FLAC__stream_decoder_get_state(decoder)]);
    
    size_t sz = frame->header.blocksize * frame->header.channels * 2;
    void *tmp = malloc(sz);
    void *tail = tmp;
    
    printf("sz = %lu\n", sz);
   
    for (int i = 0; i < frame->header.blocksize; i++) {
        for (int j = 0; j < frame->header.channels; j++) {
            memcpy(tail, (void *)&buffer[j][i], 2);
            tail += 2;
        }
    }
    
    [h.delegate onAvailableData:h data:tmp numBytes:(UInt32)sz numPacketDescs:0 packetDescs:NULL];
    
    free(tmp);
    return FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
}

void flacStreamDecoderErrorCallback(const FLAC__StreamDecoder *decoder, FLAC__StreamDecoderErrorStatus status, void *client_data) {
    printf("flac error cb %d\n", status);
}

void flacStreamDecoderMetadataCallback(const FLAC__StreamDecoder *decoder, const FLAC__StreamMetadata *metadata, void *clientData) {
    
    FLACStreamHandler *h = (__bridge FLACStreamHandler *)clientData;

    if (metadata->type == FLAC__METADATA_TYPE_STREAMINFO) {
        FLAC__StreamMetadata_StreamInfo *info = &metadata->data;
        printf("Sample Rate = %u\n", info->sample_rate);
        printf("Bits/sample = %u\n", info->bits_per_sample);
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            AudioStreamBasicDescription asbd2 = {
                .mFormatID = kAudioFormatLinearPCM,
                .mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
                .mSampleRate = info->sample_rate,
                .mChannelsPerFrame = info->channels,
                .mBitsPerChannel = info->bits_per_sample,
                .mBytesPerPacket = 4,
                .mFramesPerPacket = 1,
                .mBytesPerFrame = 4,
                .mReserved = 0
            };
            
            [h.delegate onBasicDescriptionAvailable:h audioDescription:asbd2];
        });
    }
}

@implementation FLACStreamHandler

- (instancetype)initWithDelegate:(id<BBXAudioHandlerDelegate>)delegate
{
    if ((self = [super init]) && self != nil) {
        _delegate = delegate;
        
        vbuf_init(&flacBuffer, AUDIO_BUFFER_SIZE);
        pthread_mutex_init(&flacBufferLock, NULL);
    }
    
    return self;
}

- (void)feedData:(void *)buf ofSize:(size_t)bufSize
{
    
    printf("OMGHERE %lu\n", bufSize);
    
    bytesRead += bufSize;
    
    pthread_mutex_lock(&flacBufferLock);
    vbuf_append(&flacBuffer, buf, bufSize);
    pthread_mutex_unlock(&flacBufferLock);


    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//    AudioStreamBasicDescription asbd2 = {
//        .mFormatID = kAudioFormatLinearPCM,
//        .mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
//        .mSampleRate = 44100,
//        .mChannelsPerFrame = 2,
//        .mBitsPerChannel = 16,
//        .mBytesPerPacket = 4,
//        .mFramesPerPacket = 1,
//        .mBytesPerFrame = 4,
//        .mReserved = 0
//    };
//    
// 
//    [self.delegate onBasicDescriptionAvailable:self audioDescription:asbd2];
        
        decoder = FLAC__stream_decoder_new();
        FLAC__stream_decoder_init_stream(decoder, flacStreamDecoderReadCallback, NULL, NULL, NULL, NULL, flacStreamDecoderWriteCallback, flacStreamDecoderMetadataCallback, flacStreamDecoderErrorCallback, (__bridge void *)self);
        
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(q, ^{
            while (true) {
                FLAC__stream_decoder_process_single(decoder);
            }
//            FLAC__stream_decoder_process_until_end_of_stream(decoder);
            //            printf("doneeee\n");
            //            while (vbuf_size(&pcmBuffer) > 0) {
            //                void * tmp = malloc(AUDIO_BUFFER_SIZE);
            //                size_t amt = vbuf_read(&pcmBuffer, tmp, AUDIO_BUFFER_SIZE);
            //                [self.delegate onAvailableData:self data:tmp numBytes:(UInt32)amt numPacketDescs:0 packetDescs:NULL];
            //
            //            }
        });
    });
}


- (void)dispose {
    
}

@end
