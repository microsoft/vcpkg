vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/protobuf
    REF "v${VERSION}"
    SHA512 5359775e3edf6b3a67b5f38a086112cf7da2f94060d0e600375754beb3a68d557f9174f0ed21b8c51b030a40e74605e59d0785eeb54e67c8fb513fbf8dda43e0
    HEAD_REF main
    PATCHES
        fix-cmake.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/third_party/utf8_range"
    OPTIONS
        "-Dutf8_range_ENABLE_TESTS=off"
        "-Dprotobuf_VERSION=${VERSION}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "utf8_range" CONFIG_PATH "lib/cmake/utf8_range")

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/third_party/utf8_range/LICENSE")
