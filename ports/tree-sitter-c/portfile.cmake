if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tree-sitter/tree-sitter-c
    REF "v${VERSION}"
    SHA512 51cf052230ee835d4ae5e6c5adb24aeaeba3b4f106aceefaf4000bd0e57321946f1b3e3b0f9ea71d1c17a618604c6c7269c80c3ecc5ca17e22c883ff5ce4c304
    HEAD_REF master
    PATCHES
        pkgconfig.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DTREE_SITTER_CLI=${CURRENT_HOST_INSTALLED_DIR}/tools/tree-sitter-cli/tree-sitter${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        -DTREE_SITTER_REUSE_ALLOCATOR=ON
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
