//
//  GrowableBuffer.c
//  TBDAudioPlayer
//
//  Created by Christopher Lucas on 6/4/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

#include "vbuf.h"

void vbuf_init(vbuf_t *buf, size_t init_sz) {
    buf->data = malloc(init_sz);
    buf->data_sz = init_sz;
    buf->data_pos = buf->data;
}

void vbuf_free(vbuf_t *buf) {
    free(buf->data);
}

void vbuf_grow(vbuf_t *buf) {
    size_t sz = vbuf_size(buf);
    size_t new_cap = (buf->data_sz + 1) * 2;
    buf->data = realloc(buf->data, new_cap);
    buf->data_sz = new_cap;
    buf->data_pos = buf->data + sz;
}

size_t vbuf_bytes_left(vbuf_t *buf) {
    return buf->data_sz - vbuf_size(buf);
}

size_t vbuf_size(vbuf_t *buf) {
    return buf->data_pos - buf->data;
}

size_t vbuf_cap(vbuf_t *buf) {
    return buf->data_sz;
}

void vbuf_append(vbuf_t *buf, void *data, size_t data_sz) {
    while (data_sz > vbuf_bytes_left(buf)) {
        vbuf_grow(buf);
    }
    
    memcpy(buf->data_pos, data, data_sz);
    buf->data_pos += data_sz;
}

size_t vbuf_read(vbuf_t *buf, void *out, size_t bytes_want) {
    size_t sz = vbuf_size(buf);
    if (bytes_want > sz) {
        bytes_want = sz;
    }
    
    memcpy(out, buf->data, bytes_want);
    
    void *new_head = buf->data + bytes_want;
    size_t bytes_to_shift = buf->data_pos - new_head;
    for (int i = 0; i < bytes_to_shift; i++) {
        ((uint8_t *)buf->data)[i] = ((uint8_t *)new_head)[i];
    }
    
    buf->data_pos = buf->data + bytes_to_shift;
    
    return bytes_want;
}

void vbuf_flush(vbuf_t *buf) {
    buf->data_pos = buf->data;
}