//
//  BBXHTTPAudioSource.m
//  Boombox
//
//  Created by Christopher Lucas on 6/21/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import "BBXHTTPAudioSource.h"

#import "vbuf.h"

@interface BBXHTTPAudioSource () <NSURLSessionDataDelegate>

@property NSURLSession *session;
@property NSURLSessionDataTask *task;
@property NSLock *bufLock;

@end

@implementation BBXHTTPAudioSource {
    vbuf_t buf;
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    vbuf_init(&buf, 0);
    _bufLock = [[NSLock alloc] init];
    
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    _task = [_session dataTaskWithURL:url];
    [_task resume];
    
    return self;
}

- (size_t)readData:(void *)buffer ofSize:(size_t)bufSize
{
    [self.bufLock lock];
    size_t bytesRead = vbuf_read(&buf, buffer, bufSize);
    [self.bufLock unlock];
    return bytesRead;
}

- (BOOL)reachedEndOfFile
{
    return self.task.countOfBytesReceived > 0 && self.task.countOfBytesExpectedToReceive == self.task.countOfBytesReceived && vbuf_size(&buf) == 0;
}

- (void)close
{
    [self.task cancel];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.bufLock lock];
    vbuf_append(&buf, (void *)data.bytes, data.length);
    [self.bufLock unlock];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    
}

@end
