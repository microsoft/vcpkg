#include <whisper.h>

#if defined(VULKAN_HPP_DISPATCH_LOADER_DYNAMIC) && VULKAN_HPP_DISPATCH_LOADER_DYNAMIC == 1
#include <vulkan/vulkan.hpp>
VULKAN_HPP_DEFAULT_DISPATCH_LOADER_DYNAMIC_STORAGE
#endif

int main()
{
    auto context_params = whisper_context_default_params();
    return 0;
}
