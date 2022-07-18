# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF 9f73b931f402f23554a60015924e7e35c7047487 #v1.3.221
    SHA512 4d566ea02ec9c20310a90fbef09ee1550ba3b0cd02db540733d985e83b07b8da3b46ec16c3cdddba5c057511bedd5efbf9514e3e6ed8f31520ee4fc6a40868bb
    HEAD_REF master
)

file(TO_CMAKE_PATH "$ENV{VULKAN_SDK}" VULKAN_DIR)
message("VULKAN_DIR: ${VULKAN_DIR}")
get_filename_component(VULKAN_VERSION "${VULKAN_DIR}" NAME)
if (VULKAN_VERSION VERSION_LESS 1.3.216)
    message(FATAL_ERROR "${PORT} requires to install Vulkan SDK version greater equal than 1.3.216")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
