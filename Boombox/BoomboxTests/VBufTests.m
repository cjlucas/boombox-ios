//
//  VBufTests.m
//  TBDAudioPlayer
//
//  Created by Christopher Lucas on 6/4/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "vbuf.h"

@interface VBufTests : XCTestCase {
    vbuf_t buf;
}

@end

bool bytesEqual(void *a, void *b, size_t n) {
    for (int i = 0; i < n; i++) {
        if (((uint8_t *)a)[i] != ((uint8_t *)b)[i]) {
            return false;
        }
    }
    
    return true;
}

@implementation VBufTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    vbuf_free(&buf);
}

- (void)testInit {
    // This is an example of a functional test case.
    vbuf_init(&buf, 5);
    XCTAssertEqual(buf.data_sz, 5);
    XCTAssertEqual(buf.data, buf.data_pos);
}

- (void)testAppend {
    vbuf_init(&buf, 10);
    uint8_t bytes[] = {0x0, 0x1, 0x2};
    vbuf_append(&buf, bytes, sizeof(bytes));
    
    XCTAssertEqual(buf.data_pos, buf.data + 3, "tail should be set properly");
    XCTAssert(bytesEqual(bytes, buf.data, 3), "bytes should equal input");
    
    uint8_t bytes2[] = {0x3, 0x4, 0x5};
    
    vbuf_append(&buf, bytes2, sizeof(bytes2));
    XCTAssertEqual(buf.data_pos, buf.data + 6, "tail should be set properly");
    
    uint8_t expected[] = {0x0, 0x1, 0x2, 0x3, 0x4, 0x5};
    XCTAssert(bytesEqual(expected, buf.data, 6), "should equal all appended bytes");
}

- (void)testAppendWithGrow1 {
    vbuf_init(&buf, 0);
    uint8_t bytes[] = {0x0, 0x1, 0x2};
    vbuf_append(&buf, bytes, sizeof(bytes));
    XCTAssert(buf.data_sz >= 3, "underlying array should have grown greater than size of input buffer");
    
    XCTAssert(bytesEqual(bytes, buf.data, 3), "bytes appended should equal input");
}

- (void)testRead {
    vbuf_init(&buf, 10);
    uint8_t input[] = {0x0, 0x1, 0x2};
    vbuf_append(&buf, input, sizeof(input));
    
    
    uint8_t actual[3];
    XCTAssertEqual(vbuf_read(&buf, actual, sizeof(actual)), sizeof(actual));
    XCTAssert(bytesEqual(actual, input, 3), "bytes read should equal input");
    XCTAssertEqual(buf.data, buf.data_pos, "tail should have been reset");
}

- (void)testReadLessThanTotal {
    vbuf_init(&buf, 10);
    
    uint8_t input[10] = {0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9};
    vbuf_append(&buf, input, sizeof(input));
    
    uint8_t actual[5];
    XCTAssertEqual(vbuf_read(&buf, actual, sizeof(actual)), sizeof(actual), "should have only read size of given buffer");
    XCTAssert(bytesEqual(input, actual, 5), "read bytes should equal beginning of input");
    XCTAssertEqual(buf.data_pos, buf.data + 5, "tail should be set properly");
}

- (void)testReadGreaterThanTotal {
    vbuf_init(&buf, 2);
    
    uint8_t input[2] = {0x0, 0x1};
    vbuf_append(&buf, input, sizeof(input));
    
    uint8_t actual[5];
    XCTAssertEqual(vbuf_read(&buf, actual, sizeof(actual)), sizeof(input), "should have only read size of input");
    XCTAssert(bytesEqual(input, actual, 2), "read bytes should equal beginning of input");
    XCTAssertEqual(buf.data_pos, buf.data, "tail should be set properly");
}

- (void)testSizeNoAppend{
    vbuf_init(&buf, 2);
    XCTAssertEqual(vbuf_size(&buf), 0);
}

- (void)testSizeAppendLessThanCapacity {
    vbuf_init(&buf, 10);
   
    uint8_t input[5] = {0x0, 0x1, 0x2, 0x3, 0x4};
    vbuf_append(&buf, input, sizeof(input));
    
    XCTAssertEqual(vbuf_size(&buf), sizeof(input), "should equal the size of input");
}


@end
