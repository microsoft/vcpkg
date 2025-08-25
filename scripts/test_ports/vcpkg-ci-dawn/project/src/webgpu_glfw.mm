#if defined(__APPLE__)
#include "webgpu_glfw.hpp"

#import <QuartzCore/CAMetalLayer.h>

#include "GLFW/glfw3.h"

#define GLFW_EXPOSE_NATIVE_COCOA
#include "GLFW/glfw3native.h"

namespace wgpu::glfw {

std::unique_ptr<wgpu::ChainedStruct> SetupWindowAndGetSurfaceDescriptorCocoa(GLFWwindow *window) {
    @autoreleasepool {
        NSWindow *nsWindow = glfwGetCocoaWindow(window);
        NSView *view = [nsWindow contentView];
        [view setWantsLayer:YES];
        [view setLayer:[CAMetalLayer layer]];
        [[view layer] setContentsScale:[nsWindow backingScaleFactor]];
        auto desc = std::make_unique<wgpu::SurfaceSourceMetalLayer>();
        desc->layer = [view layer];
        return desc;
    }
}

}  // namespace wgpu::glfw
#endif  // defined(__APPLE__)
