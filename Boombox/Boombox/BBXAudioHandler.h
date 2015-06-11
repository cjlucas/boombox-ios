//
//  AbsAudioHandler.h
//  TBDAudioPlayer
//
//  Created by Christopher Lucas on 6/3/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define NUM_AUDIO_BUFFERS (1 << 2)
#define AUDIO_BUFFER_SIZE (1 << 16)

void audioHandlerAudioQueueCallback(void *in, AudioQueueRef aq, AudioQueueBufferRef buf);

@class BBXAudioHandler;

@protocol BBXAudioHandlerDelegate <NSObject>
- (void)onAvailableData:(BBXAudioHandler *)handler data:(void *)bytes numBytes:(UInt32)numBytes numPacketDescs:(UInt32)numPacketDescs packetDescs:(AudioStreamPacketDescription *)packetDescs;
- (void)onBasicDescriptionAvailable:(BBXAudioHandler *)handler audioDescription:(AudioStreamBasicDescription)desc;
@end

@interface BBXAudioHandler : NSObject {
    AudioStreamBasicDescription asbd;
}

@property (readonly) BOOL done;
@property (weak) id<BBXAudioHandlerDelegate> delegate;

- (instancetype)init;
- (void)feedData:(void *)buf ofSize:(size_t)bufSize;
- (void)dispose;
@end
