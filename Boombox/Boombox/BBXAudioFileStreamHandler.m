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
    printf("audioFileHandlerPropProc\n");
    [h onProperty:afsid propId:propid flags:ioFlags];
}

void audioFileHandlerPacketProc(void *inClientData, UInt32 numBytes, UInt32 numPackets, const void *data, AudioStreamPacketDescription *packetDescs)
{
    BBXAudioFileStreamHandler *h = (__bridge BBXAudioFileStreamHandler *)inClientData;
    printf("audioFileHandlerPacketProc\n");
    [h onPacket:numBytes numPackets:numPackets data:data packetDescs:packetDescs];
}

@implementation BBXAudioFileStreamHandler

@synthesize done;

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        if (AudioFileStreamOpen((__bridge void *)self, audioFileHandlerPropProc, audioFileHandlerPacketProc, 0, &audioFileStreamId)) {
            NSLog(@"AudioFileStreamOpen error");
        }
    }
    
    return self;
}

- (BOOL)done
{
    return NO;
}

- (void)feedData:(void *)buf ofSize:(size_t)bufSize
{
    printf("feedData!\n");
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
            } else if (self.delegate != nil) {
                [self.delegate onBasicDescriptionAvailable:self audioDescription:asbd];
            }
            break;
    }
}

- (void)onPacket:(UInt32)numbytes numPackets:(UInt32)numPackets data:(const void *)data packetDescs:(AudioStreamPacketDescription *)packetDescs;
{
    printf("HERE!!\n");
    if (self.delegate != nil) {
        [self.delegate onAvailableData:self data:(void *)data numBytes:numbytes numPacketDescs:numPackets packetDescs:packetDescs];
    }
}

@end
