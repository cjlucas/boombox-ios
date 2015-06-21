//
//  BBXAudioQueueBufferManager.h
//  Boombox
//
//  Created by Christopher Lucas on 6/6/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

void bbxAudioQueueOutputCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer);

@interface BBXAudioQueueBufferManager : NSObject

- (void)allocateBuffersWithQueue:(AudioQueueRef)audioQueue numBuffers:(UInt32)numBuffers andBufferSize:(UInt32)bufferSize;

- (BOOL)addDataToQueue:(AudioQueueRef)audioQueue bytes:(void *)bytes ofSize:(UInt32)numBytes withPacketDescriptions:(AudioStreamPacketDescription *)descs numPackets:(UInt32)numPackets;

- (void)enqueueRemainingData:(AudioQueueRef)audioQueue;
- (void)flush;

- (void)reuseAudioBuffer:(AudioQueueBufferRef)buffer;

@end
