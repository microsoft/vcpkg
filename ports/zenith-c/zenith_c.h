/* 
 * Zenith-C: The Ultimate OOP Framework for Procedural C
 * 
 * Copyright (c) 2026 Aksheita Dholakia
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef ZENITH_C_H
#define ZENITH_C_H

#include <stdlib.h>
#include <string.h>

// --- THE CORE ENGINE ---

struct zc_vnode {
    const char* type_name;
    void* table;
    struct zc_vnode* next;
};

#define ZC_CLASS(name) \
    typedef struct name name; \
    struct name##_vtable; \
    struct name { \
        struct zc_vnode* vlist;

#define ZC_METHODS(name) \
    }; \
    struct name##_vtable {

#define ZC_END_CLASS };

// --- THE FACTORY (Universal Constructor) ---
// This version works on ALL compilers (GCC, Clang, MSVC)
#define ZC_NEW(ptr, type, ...) \
    do { \
        ptr = (type*)malloc(sizeof(type)); \
        if (ptr) zc_init_##type(ptr, ##__VA_ARGS__); \
    } while(0)

// --- THE DESTRUCTOR (Memory Cleaner) ---
// This macro clears the linked list nodes AND the object itself
#define ZC_DELETE(obj) \
    do { \
        if (obj) { \
            struct zc_vnode* current = (obj)->vlist; \
            while (current) { \
                struct zc_vnode* next = current->next; \
                free(current); \
                current = next; \
            } \
            free(obj); \
            obj = NULL; \
        } \
    } while(0)

// --- THE UTILS ---
static inline void* zc_get_vtable(struct zc_vnode* head, const char* name) {
    while(head) {
        if(strcmp(head->type_name, name) == 0) return head->table;
        head = head->next;
    }
    return NULL;
}

static inline struct zc_vnode* zc_attach(struct zc_vnode* head, const char* name, void* table) {
    struct zc_vnode* node = (struct zc_vnode*)malloc(sizeof(struct zc_vnode));
    if (!node) return head;
    node->type_name = name;
    node->table = table;
    node->next = head;
    return node;
}

#endif // ZENITH_C_H
