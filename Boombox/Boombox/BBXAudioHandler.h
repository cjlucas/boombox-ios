//
//  AbsAudioHandler.h
//  TBDAudioPlayer
//
//  Created by Christopher Lucas on 6/3/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol BBXAudioHandler;

@protocol BBXAudioHandlerDelegate <NSObject>
- (void)onAvailableData:(id <BBXAudioHandler>)handler data:(void *)bytes numBytes:(UInt32)numBytes numPacketDescs:(UInt32)numPacketDescs packetDescs:(AudioStreamPacketDescription *)packetDescs;
- (void)onBasicDescriptionAvailable:(id <BBXAudioHandler>)handler audioDescription:(AudioStreamBasicDescription)desc;
@end

@protocol BBXAudioHandler <NSObject>

- (instancetype)initWithDelegate:(id <BBXAudioHandlerDelegate>)delegate;
- (void)feedData:(void *)buf ofSize:(size_t)bufSize;
- (void)dispose;

@end