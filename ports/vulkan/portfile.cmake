# This package just verifies that the Vulkan SDK is installed.
set(VCPKG_BUILD_TYPE release)
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(DEFINED ENV{VULKAN_SDK})
    message(STATUS "VULKAN_SDK environment variable: $ENV{VULKAN_SDK}")
endif()

set(vulkan_result_file "${CURRENT_BUILDTREES_DIR}/vulkan-${TARGET_TRIPLET}.cmake.log")
vcpkg_cmake_configure(
    SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}"
    OPTIONS
        "-DVCPKG_VULKAN_VERSION=${VERSION}"
    OPTIONS_RELEASE
        "-DOUTFILE=${vulkan_result_file}"
)

include("${vulkan_result_file}")
if(DETECTED_Vulkan_FOUND)
    message(STATUS "Found Vulkan SDK ${DETECTED_Vulkan_VERSION} (${DETECTED_Vulkan_LIBRARIES})")
else()
    set(message "The Vulkan SDK wasn't found. ")
    if(VCPKG_TARGET_IS_WINDOWS)
        string(APPEND message "Refer to Getting Started with the Windows Vulkan SDK: https://vulkan.lunarg.com/doc/sdk/latest/windows/getting_started.html")
    elseif(VCPKG_TARGET_IS_OSX)
        string(APPEND message "Refer to Getting Started with the MacOS Vulkan SDK: https://vulkan.lunarg.com/doc/sdk/latest/mac/getting_started.html")
    elseif(VCPKG_TARGET_IS_LINUX)
        string(APPEND message "Refer to Getting Started with the Linux Vulkan SDK: https://vulkan.lunarg.com/doc/sdk/latest/linux/getting_started.html")
    endif()
    message(FATAL_ERROR "${message}")
endif()

find_file(vulkan_license NAMES LICENSE.txt PATHS ${DETECTED_Vulkan_INCLUDE_DIRS} "${CURRENT_PORT_DIR}" PATH_SUFFIXES "..")
vcpkg_install_copyright(FILE_LIST "${vulkan_license}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
