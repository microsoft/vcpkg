set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(components COMPONENTS "")
if("${CMAKE_VERSION}" VERSION_GREATER_EQUAL "3.29.0")
    list(APPEND components glslang)
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND components dxc)
endif()

# FindVulkan.cmake checks the version of the Vulkan SDK by comparing the version string with the version of the vulkan-headers.
# Vulkan headers dont use the build number, so even if they technically tag new version number with a build number, it cannot be parsed correctly by FindVulkan.cmake.
string(REGEX REPLACE "^([0-9]+\\.[0-9]+\\.[0-9]+)(\\.[0-9]+)?$" "\\1" VERSION_TRIMMED "${VERSION}")
set(vulkan_result_file "${CURRENT_BUILDTREES_DIR}/vulkan-${TARGET_TRIPLET}.cmake.log")
vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_INSTALLED_DIR}/share/vulkan/detect-vulkan"
    OPTIONS
        "-DVCPKG_VULKAN_VERSION=${VERSION_TRIMMED}"
        "-DVCPKG_VULKAN_COMPONENTS=${components}"
    OPTIONS_RELEASE
        "-DOUTFILE=${vulkan_result_file}"
)

include("${vulkan_result_file}")
if(NOT DETECTED_Vulkan_FOUND)
    message(FATAL_ERROR "The Vulkan SDK wasn't found.")
endif()

find_file(vulkan_license NAMES LICENSE.txt PATHS ${DETECTED_Vulkan_INCLUDE_DIRS} "${CURRENT_PORT_DIR}" PATH_SUFFIXES "..")
vcpkg_install_copyright(FILE_LIST "${vulkan_license}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
