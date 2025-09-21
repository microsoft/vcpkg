vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/protobuf
    REF "v32.0" # protobuf repo does not have v6.32.0 tag for C++ runtime
    SHA512 89806b219fa2132e46bf01b7a5831c2977ad7ebe06750956d0e17bcdc028498e883704445fca56bb813f4b78e935709f67f8fa1b46b597840c58a843483cdafb
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
