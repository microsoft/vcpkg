set(VCPKG_LIBRARY_LINKAGE dynamic)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Loader
    REF "vulkan-sdk-${VERSION}"
    SHA512 535b7f324348e9edf44ff6a6a6e9eabe6e3a4bfad79bef789d1dc0cbbe3de36b6495a05236323d155631b081b89c18bb8668c79d1f735b59fc85ebee555aa682
    HEAD_REF main
    PATCHES
        0001-fix-comments-and-lib.patch
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TESTS:BOOL=OFF
    -DPython3_EXECUTABLE=${PYTHON3}
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/VulkanLoader" PACKAGE_NAME VulkanLoader)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
