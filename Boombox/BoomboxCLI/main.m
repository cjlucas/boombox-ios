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

int main(int argc, const char * argv[]) {
    // insert code here...
    NSLog(@"Hello, World!");
    
    BBXPlayer *player = [[BBXPlayer alloc] init];
    NSURL *url = [NSURL URLWithString:@"https://archive.org/download/johnmayer2008-08-02.DPA4023.flac16/John_Mayer_2008-08-02_t05.mp3"];
    [player addURL:url];
    [player play];
    
    playing = true;
    
    
//    while (true) { playing ? [m stop] : [m play]; playing = !playing; sleep(2); };
    while (playing) { sleep(5); }
    
    return 0;
}
