#include <llama.h>

// Verify that ggml::ggml-vulkan can be used with apps which
// instantiate VULKAN_HPP_DEFAULT_DISPATCH_LOADER_DYNAMIC_STORAGE.
#if defined(VULKAN_HPP_DISPATCH_LOADER_DYNAMIC) && VULKAN_HPP_DISPATCH_LOADER_DYNAMIC == 1
#include <vulkan/vulkan.hpp>
VULKAN_HPP_DEFAULT_DISPATCH_LOADER_DYNAMIC_STORAGE
#endif

int main()
{
    auto context_params = llama_context_default_params();
    ggml_backend_load_all();
    return 0;
}
