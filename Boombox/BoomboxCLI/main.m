//
//  main.m
//  BoomboxCLI
//
//  Created by Christopher Lucas on 6/6/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Boombox/Boombox.h>

bool playing = false;

BBXFileAudioSource *fileSourceWithPath(const char *cpath)
{
    
    NSString *fpath = [NSString stringWithUTF8String:cpath];
    
    BBXFileAudioSource *src = [[BBXFileAudioSource alloc] initWithURL:[NSURL fileURLWithPath:fpath]];
    NSLog(@"%@", src);
    if (src == nil) {
        return nil;
    }
    
    return src;
}

int main(int argc, const char * argv[]) {
    // insert code here...
//    NSLog(@"Hello, World!");
//    
//    Thing *t = [[Thing alloc] init];
//    
//    handler = [[BBXAudioQueueBufferManager alloc] init];
//    BBXAudioHandler *h = [[BBXAudioFileStreamHandler alloc] init];
//    h.delegate = t;
//    
//    FILE *fp = fopen(argv[argc-1], "rb");
//    if (fp == NULL) {
//        return EXIT_FAILURE;
//    }
//    
//    char buf[1 << 16];
//    while (!feof(fp)) {
//        size_t bytes_read = fread(buf, 1, 1 << 16, fp);
//        if (bytes_read <= 0)break;
//        [h feedData:buf ofSize:bytes_read];
//    }
//    
//    NSLog(@"done reading");
//    
//    while (true) {
//        sleep(5);
//    }

    BBXAudioEngine *m = [[BBXAudioEngine alloc] init];
   
    [m queueAudioSource:fileSourceWithPath(argv[1])];
    [m queueAudioSource:fileSourceWithPath(argv[2])];
    
//    while (true) { playing ? [m stop] : [m play]; playing = !playing; sleep(2); };
    while (true) { sleep(5); }
    
    return 0;
}
