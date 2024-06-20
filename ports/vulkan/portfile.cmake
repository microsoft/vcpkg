set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(vulkan_result_file "${CURRENT_BUILDTREES_DIR}/vulkan-${TARGET_TRIPLET}.cmake.log")
vcpkg_cmake_configure(
    SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}"
    OPTIONS_RELEASE
        "-DOUTFILE=${vulkan_result_file}"
)

include("${vulkan_result_file}")
if(DETECTED_Vulkan_FOUND)
    message(STATUS "Found Vulkan ${DETECTED_Vulkan_VERSION} (${DETECTED_Vulkan_LIBRARIES})")
else()
    set(message "Vulkan wasn't found.")
    if(VCPKG_TARGET_IS_ANDROID AND DETECTED_ANDROID_NATIVE_API_LEVEL AND DETECTED_ANDROID_NATIVE_API_LEVEL LESS "24")
        string(APPEND message " Vulkan support from the Android NDK requires API level 24 (found: ${DETECTED_ANDROID_NATIVE_API_LEVEL})")
    endif()
    message(FATAL_ERROR "${message}")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
             "${CMAKE_CURRENT_LIST_DIR}/vulkan-result.cmake.in"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/detect-vulkan"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" [[
This is a stub package. Copyright and license information
is provided with Vulkan headers and loader.
For Android, the loader is provided by the NDK.
]])
