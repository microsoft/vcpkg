#include "webgpu_glfw.hpp"

#include <webgpu/webgpu_cpp.h>

#include <memory>

#include "GLFW/glfw3.h"

#if defined(_WIN32)
#define GLFW_EXPOSE_NATIVE_WIN32
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

#if !defined(__EMSCRIPTEN__)
#include "GLFW/glfw3native.h"
#endif

namespace wgpu::glfw {

std::unique_ptr<wgpu::ChainedStruct> SetupWindowAndGetSurfaceDescriptorCocoa(GLFWwindow *window);

std::unique_ptr<wgpu::ChainedStruct> SetupWindowAndGetSurfaceDescriptor(GLFWwindow *window) {
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
    return SetupWindowAndGetSurfaceDescriptorCocoa(window);
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

wgpu::Surface CreateSurfaceForWindow(const wgpu::Instance &instance, GLFWwindow *window) {
    auto chainedDescriptor = SetupWindowAndGetSurfaceDescriptor(window);
    wgpu::SurfaceDescriptor descriptor;
    descriptor.nextInChain = chainedDescriptor.get();
    wgpu::Surface surface = instance.CreateSurface(&descriptor);
    return surface;
}

}  // namespace wgpu::glfw
