//
// Copyright (c) 2025 xiaozhuai
//

#define GLFW_INCLUDE_NONE

#include <memory>

#include "GLFW/glfw3.h"
#include "webgpu/webgpu_cpp.h"

#if defined(_WIN32)
#define GLFW_EXPOSE_NATIVE_WIN32
#endif

#if defined(__APPLE__)
#define GLFW_EXPOSE_NATIVE_COCOA
#endif

#if defined(__linux__)
#define DAWN_USE_X11
#endif

#if defined(DAWN_USE_X11)
#define GLFW_EXPOSE_NATIVE_X11
#endif

#if defined(DAWN_USE_WAYLAND)
#define GLFW_EXPOSE_NATIVE_WAYLAND
#endif

#if defined(__EMSCRIPTEN__)
#include "emscripten/emscripten.h"
#else
#include "GLFW/glfw3native.h"
#endif

#if defined(__APPLE__)
#include <objc/message.h>
#include <objc/objc.h>
#include <objc/runtime.h>
template <typename T, typename... Args>
T objc_call(id obj, const char *sel, Args... args) {
    using FuncPtr = T (*)(id, SEL, Args...);
    return reinterpret_cast<FuncPtr>(objc_msgSend)(obj, sel_registerName(sel), args...);
}
template <typename T, typename... Args>
T objc_call(const char *clazz, const char *sel, Args... args) {
    return objc_call<T>(reinterpret_cast<id>(objc_getClass(clazz)), sel, args...);
}
#endif

std::unique_ptr<wgpu::ChainedStruct> setup_window_and_get_surface_descriptor(GLFWwindow *window) {
    if (glfwGetWindowAttrib(window, GLFW_CLIENT_API) != GLFW_NO_API) {
        return nullptr;
    }

#if defined(__EMSCRIPTEN__)
    auto desc = std::make_unique<wgpu::EmscriptenSurfaceSourceCanvasHTMLSelector>();
    desc->selector = "#canvas";
    return desc;
#elif defined(_WIN32)
    auto desc = std::make_unique<wgpu::SurfaceSourceWindowsHWND>();
    desc->hwnd = glfwGetWin32Window(window);
    desc->hinstance = GetModuleHandle(nullptr);
    return desc;
#elif defined(__APPLE__)
    // NSWindow *ns_window = glfwGetCocoaWindow(window);
    // NSView *view = [ns_window contentView];
    // [view setWantsLayer:YES];
    // CAMetalLayer *layer = [CAMetalLayer layer];
    // CGFloat scale_factor = [ns_window backingScaleFactor];
    // [layer setContentsScale:scale_factor];
    // [view setLayer:layer];
    auto ns_window = glfwGetCocoaWindow(window);
    CFRetain(ns_window);
    auto view = objc_call<id>(ns_window, "contentView");
    CFRetain(view);
    objc_call<void, BOOL>(view, "setWantsLayer:", YES);
    auto layer = objc_call<id>("CAMetalLayer", "layer");
    auto scale_factor = objc_call<CGFloat>(ns_window, "backingScaleFactor");
    objc_call<void, CGFloat>(layer, "setContentsScale:", scale_factor);
    objc_call<void, id>(view, "setLayer:", layer);
    auto desc = std::make_unique<wgpu::SurfaceSourceMetalLayer>();
    desc->layer = layer;
    CFRelease(view);
    CFRelease(ns_window);
    return desc;
#elif defined(DAWN_USE_WAYLAND) || defined(DAWN_USE_X11)
#if defined(GLFW_PLATFORM_WAYLAND) && defined(DAWN_USE_WAYLAND)
    if (glfwGetPlatform() == GLFW_PLATFORM_WAYLAND) {
        auto desc = std::make_unique<wgpu::SurfaceSourceWaylandSurface>();
        desc->display = glfwGetWaylandDisplay();
        desc->surface = glfwGetWaylandWindow(window);
        return desc;
    } else  // NOLINT(readability/braces)
#endif
#if defined(DAWN_USE_X11)
    {
        auto desc = std::make_unique<wgpu::SurfaceSourceXlibWindow>();
        desc->display = glfwGetX11Display();
        desc->window = glfwGetX11Window(window);
        return desc;
    }
#else
    {
        return nullptr;
    }
#endif
#else
    return nullptr;
#endif
}

wgpu::Surface create_surface(const wgpu::Instance &instance, GLFWwindow *window) {
    auto chainedDescriptor = setup_window_and_get_surface_descriptor(window);
    wgpu::SurfaceDescriptor descriptor;
    descriptor.nextInChain = chainedDescriptor.get();
    wgpu::Surface surface = instance.CreateSurface(&descriptor);
    return surface;
}
