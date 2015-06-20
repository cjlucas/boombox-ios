//
//  AudioFileHandler.m
//  TBDAudioPlayer
//
//  Created by Christopher Lucas on 6/3/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXAudioFileStreamHandler.h"

void audioFileHandlerPropProc(void *inClientData, AudioFileStreamID afsid, AudioFileStreamPropertyID propid, UInt32 *ioFlags)
{
    BBXAudioFileStreamHandler *h = (__bridge BBXAudioFileStreamHandler *)inClientData;
    [h onProperty:afsid propId:propid flags:ioFlags];
}

void audioFileHandlerPacketProc(void *inClientData, UInt32 numBytes, UInt32 numPackets, const void *data, AudioStreamPacketDescription *packetDescs)
{
    BBXAudioFileStreamHandler *h = (__bridge BBXAudioFileStreamHandler *)inClientData;
    [h onPacket:numBytes numPackets:numPackets data:data packetDescs:packetDescs];
}

@implementation BBXAudioFileStreamHandler

- (instancetype)initWithDelegate:(id<BBXAudioHandlerDelegate>)delegate
{
    self = [super init];
    if (self != nil) {
        _delegate = delegate;
        if (AudioFileStreamOpen((__bridge void *)self, audioFileHandlerPropProc, audioFileHandlerPacketProc, 0, &audioFileStreamId)) {
            NSLog(@"AudioFileStreamOpen error");
        }
    }
    
    return self;
}

- (void)feedData:(void *)buf ofSize:(size_t)bufSize
{
    if (AudioFileStreamParseBytes(audioFileStreamId, (UInt32)bufSize, buf, 0)) {
        NSLog(@"AudioFileStreamParseBytes error");
    }
}

- (void)onProperty:(AudioFileStreamID)afsid propId:(AudioFileStreamPropertyID)propid flags:(UInt32 *)ioFlags
{
    switch(propid) {
        case kAudioFileStreamProperty_DataFormat:
            printf("getting data format\n");
            UInt32 asbdSize = sizeof(asbd);
            if (AudioFileStreamGetProperty(afsid, propid, &asbdSize, &asbd)) {
                printf("Failed to get data format\n");
            } else {
                [self.delegate onBasicDescriptionAvailable:self audioDescription:asbd];
            }
            break;
    }
}

- (void)onPacket:(UInt32)numbytes numPackets:(UInt32)numPackets data:(const void *)data packetDescs:(AudioStreamPacketDescription *)packetDescs;
{
    [self.delegate onAvailableData:self data:(void *)data numBytes:numbytes numPacketDescs:numPackets packetDescs:packetDescs];
}

- (void)dispose
{
    
}

@end
