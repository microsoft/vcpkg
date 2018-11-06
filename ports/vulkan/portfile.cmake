# Due to the complexity involved, this package doesn't install the Vulkan SDK.
# It instead verifies that Vulkan is installed.
# Other packages can depend on this package to declare a dependency on Vulkan.
include(vcpkg_common_functions)

if(EXISTS "$ENV{VULKAN_SDK}Include/vulkan/vulkan.h")
    message(FATAL_ERROR "Could not find Vulkan SDK. Before continuing, please download and install Vulkan from:"
                        "\n    https://vulkan.lunarg.com/sdk/home\n")
endif()

# Check if the user left the version in the installation directory e.g. c:/vulkanSDK/1.1.82.1/
if($ENV{VULKAN_SDK} MATCHES "(([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+))")
    set(VULKAN_VERSION "${CMAKE_MATCH_1}")
    set(VULKAN_MAJOR "${CMAKE_MATCH_2}")
    set(VULKAN_MINOR "${CMAKE_MATCH_3}")
    set(VULKAN_PATCH "${CMAKE_MATCH_4}")
    message(STATUS "FOUND VERSION " ${VULKAN_VERSION} " at location:\n      " $ENV{VULKAN_SDK})

    set(VULKAN_REQUIRED_VERSION "1.1.82.1")
    if (VULKAN_MAJOR LESS 1 OR VULKAN_MINOR LESS 1 OR VULKAN_PATCH LESS 82)
        message(FATAL_ERROR "Vuklan ${VULKAN_VERSION} but ${VULKAN_REQUIRED_VERSION} is required. Please download and install a more recent version from:"
                            "\n    https://vulkan.lunarg.com/sdk/home\n")
    endif()
endif()

configure_file($ENV{VULKAN_SDK}/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/vulkan/copyright COPYONLY)
SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)