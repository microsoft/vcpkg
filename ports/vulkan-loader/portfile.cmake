set(VCPKG_LIBRARY_LINKAGE dynamic)

vcpkg_download_distfile(ARM_COMMENT_SYNTAX_FIX
  URLS https://github.com/KhronosGroup/Vulkan-Loader/commit/ce3a4db90513c2dd10fbe56a21207945fbc9339f.patch?full_index=1
  SHA512 e08d0be965f2430a5353a30339e1c29e5074d5b751f7894bdfec8c2031916b0e4d39fff1dad0e5ec94e4f2f296fac230dbfcb9a04af4b2d1ad51dffe270d232a
  FILENAME vulkan-loader-arm-comment-syntax-ce3a4db90513c2dd10fbe56a21207945fbc9339f.patch
)

vcpkg_download_distfile(NINJA_CLANG_CL_WORKAROUND
  URLS https://github.com/KhronosGroup/Vulkan-Loader/commit/4b043de5655d41cee12ef73d986cb7f7a7dbc239.patch?full_index=1
  SHA512 327ce23dc1a4e68ef31a02e9847c7aa740f0a81cd62d3fecf5e7efd84149909f2377e031064346ecb6aa2c5ec094413627a3f4b34c674d8713fc1ca01f88fc22
  FILENAME vulkan-loader-clang-cl-workaround-4b043de5655d41cee12ef73d986cb7f7a7dbc239.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Loader
    REF "vulkan-sdk-${VERSION}"
    SHA512 535b7f324348e9edf44ff6a6a6e9eabe6e3a4bfad79bef789d1dc0cbbe3de36b6495a05236323d155631b081b89c18bb8668c79d1f735b59fc85ebee555aa682
    HEAD_REF main
    PATCHES
        "${ARM_COMMENT_SYNTAX_FIX}"
        "${NINJA_CLANG_CL_WORKAROUND}"
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
