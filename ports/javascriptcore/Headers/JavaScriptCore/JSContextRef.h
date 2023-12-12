/*
 * Copyright (C) 2006 Apple Inc.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef JSContextRef_h
#define JSContextRef_h

#include <JavaScriptCore/JSObjectRef.h>
#include <JavaScriptCore/JSValueRef.h>
#include <JavaScriptCore/WebKitAvailability.h>

#ifndef __cplusplus
#include <stdbool.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

/*!
@function
@abstract Creates a JavaScript context group.
@discussion A JSContextGroup associates JavaScript contexts with one another.
 Contexts in the same group may share and exchange JavaScript objects. Sharing and/or exchanging
 JavaScript objects between contexts in different groups will produce undefined behavior.
 When objects from the same context group are used in multiple threads, explicit
 synchronization is required.

 A JSContextGroup may need to run deferred tasks on a run loop, such as garbage collection
 or resolving WebAssembly compilations. By default, calling JSContextGroupCreate will use
 the run loop of the thread it was called on. Currently, there is no API to change a
 JSContextGroup's run loop once it has been created.
@result The created JSContextGroup.
*/
JS_EXPORT JSContextGroupRef JSContextGroupCreate(void) JSC_API_AVAILABLE(macos(10.6), ios(7.0));

/*!
@function
@abstract Retains a JavaScript context group.
@param group The JSContextGroup to retain.
@result A JSContextGroup that is the same as group.
*/
JS_EXPORT JSContextGroupRef JSContextGroupRetain(JSContextGroupRef group) JSC_API_AVAILABLE(macos(10.6), ios(7.0));

/*!
@function
@abstract Releases a JavaScript context group.
@param group The JSContextGroup to release.
*/
JS_EXPORT void JSContextGroupRelease(JSContextGroupRef group) JSC_API_AVAILABLE(macos(10.6), ios(7.0));

/*!
@function
@abstract Creates a global JavaScript execution context.
@discussion JSGlobalContextCreate allocates a global object and populates it with all the
 built-in JavaScript objects, such as Object, Function, String, and Array.

 In WebKit version 4.0 and later, the context is created in a unique context group.
 Therefore, scripts may execute in it concurrently with scripts executing in other contexts.
 However, you may not use values created in the context in other contexts.
@param globalObjectClass The class to use when creating the global object. Pass 
 NULL to use the default object class.
@result A JSGlobalContext with a global object of class globalObjectClass.
*/
JS_EXPORT JSGlobalContextRef JSGlobalContextCreate(JSClassRef globalObjectClass) JSC_API_AVAILABLE(macos(10.5), ios(7.0));

/*!
@function
@abstract Creates a global JavaScript execution context in the context group provided.
@discussion JSGlobalContextCreateInGroup allocates a global object and populates it with
 all the built-in JavaScript objects, such as Object, Function, String, and Array.
@param globalObjectClass The class to use when creating the global object. Pass
 NULL to use the default object class.
@param group The context group to use. The created global context retains the group.
 Pass NULL to create a unique group for the context.
@result A JSGlobalContext with a global object of class globalObjectClass and a context
 group equal to group.
*/
JS_EXPORT JSGlobalContextRef JSGlobalContextCreateInGroup(JSContextGroupRef group, JSClassRef globalObjectClass) JSC_API_AVAILABLE(macos(10.6), ios(7.0));

/*!
@function
@abstract Retains a global JavaScript execution context.
@param ctx The JSGlobalContext to retain.
@result A JSGlobalContext that is the same as ctx.
*/
JS_EXPORT JSGlobalContextRef JSGlobalContextRetain(JSGlobalContextRef ctx);

/*!
@function
@abstract Releases a global JavaScript execution context.
@param ctx The JSGlobalContext to release.
*/
JS_EXPORT void JSGlobalContextRelease(JSGlobalContextRef ctx);

/*!
@function
@abstract Gets the global object of a JavaScript execution context.
@param ctx The JSContext whose global object you want to get.
@result ctx's global object.
*/
JS_EXPORT JSObjectRef JSContextGetGlobalObject(JSContextRef ctx);

/*!
@function
@abstract Gets the context group to which a JavaScript execution context belongs.
@param ctx The JSContext whose group you want to get.
@result ctx's group.
*/
JS_EXPORT JSContextGroupRef JSContextGetGroup(JSContextRef ctx) JSC_API_AVAILABLE(macos(10.6), ios(7.0));

/*!
@function
@abstract Gets the global context of a JavaScript execution context.
@param ctx The JSContext whose global context you want to get.
@result ctx's global context.
*/
JS_EXPORT JSGlobalContextRef JSContextGetGlobalContext(JSContextRef ctx) JSC_API_AVAILABLE(macos(10.7), ios(7.0));

/*!
@function
@abstract Gets a copy of the name of a context.
@param ctx The JSGlobalContext whose name you want to get.
@result The name for ctx.
@discussion A JSGlobalContext's name is exposed when inspecting the context to make it easier to identify the context you would like to inspect.
*/
JS_EXPORT JSStringRef JSGlobalContextCopyName(JSGlobalContextRef ctx) JSC_API_AVAILABLE(macos(10.10), ios(8.0));

/*!
@function
@abstract Sets the name exposed when inspecting a context.
@param ctx The JSGlobalContext that you want to name.
@param name The name to set on the context.
*/
JS_EXPORT void JSGlobalContextSetName(JSGlobalContextRef ctx, JSStringRef name) JSC_API_AVAILABLE(macos(10.10), ios(8.0));

/*!
@function
@abstract Gets whether the context is inspectable in Web Inspector.
@param ctx The JSGlobalContext that you want to change the inspectability of.
@result Whether the context is inspectable in Web Inspector.
*/
JS_EXPORT bool JSGlobalContextIsInspectable(JSGlobalContextRef ctx) JSC_API_AVAILABLE(macos(13.3), ios(16.4));

/*!
@function
@abstract Sets whether the context is inspectable in Web Inspector. Default value is NO.
@param ctx The JSGlobalContext that you want to change the inspectability of.
@param inspectable YES to allow Web Inspector to connect to the context, otherwise NO.
*/
JS_EXPORT void JSGlobalContextSetInspectable(JSGlobalContextRef ctx, bool inspectable) JSC_API_AVAILABLE(macos(13.3), ios(16.4));

#ifdef __cplusplus
}
#endif

#endif /* JSContextRef_h */
