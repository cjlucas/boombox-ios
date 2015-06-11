//
//  AudioFileHandler.h
//  TBDAudioPlayer
//
//  Created by Christopher Lucas on 6/3/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXAudioHandler.h"

@interface BBXAudioFileStreamHandler : BBXAudioHandler {
    AudioFileStreamID audioFileStreamId;
}

- (void)onProperty:(AudioFileStreamID)afsid propId:(AudioFileStreamPropertyID)propid flags:(UInt32 *)ioFlags;
- (void)onPacket:(UInt32)numbytes numPackets:(UInt32)numPackets data:(const void *)data packetDescs:(AudioStreamPacketDescription *)packetDescs;

@end
