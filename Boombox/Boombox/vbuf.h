//
//  GrowableBuffer.h
//  TBDAudioPlayer
//
//  Created by Christopher Lucas on 6/4/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#pragma once

#include <stdlib.h>
#include <string.h>

typedef struct vbuf {
    void *data;
    size_t data_sz; // allocated size
    void *data_pos;
} vbuf_t;

void vbuf_init(vbuf_t *buf, size_t init_sz);

void vbuf_free(vbuf_t *buf);

void vbuf_grow(vbuf_t *buf);

size_t vbuf_bytes_left(vbuf_t *buf);

size_t vbuf_size(vbuf_t *buf);

void vbuf_append(vbuf_t *buf, void *data, size_t data_sz);

size_t vbuf_read(vbuf_t *buf, void *out, size_t bytes_want);

void vbuf_flush(vbuf_t *buf);