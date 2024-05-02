vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DanBloomberg/leptonica
    REF ${VERSION}
    SHA512 968a88d2074717e6f379d2f9b8f7f0d5193fe9b8856051e09e2b31c939689b196a4a9b2cde595ce76ff8ae2784680ef5e68c40709c051d3d23738e862968016f
    HEAD_REF master
    PATCHES
        fix-pc-and-config.patch
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSW_BUILD=OFF
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
        -DCMAKE_REQUIRE_FIND_PACKAGE_GIF=TRUE
        -DCMAKE_REQUIRE_FIND_PACKAGE_JPEG=TRUE
        -DCMAKE_REQUIRE_FIND_PACKAGE_PNG=TRUE
        -DCMAKE_REQUIRE_FIND_PACKAGE_TIFF=TRUE
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=TRUE
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/leptonica)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/leptonica-license.txt")
