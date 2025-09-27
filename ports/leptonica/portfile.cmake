vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DanBloomberg/leptonica
    REF "${VERSION}"
    SHA512 c430f6ddb72c4983be767d7a6a3d660a0172d2d02e27c65b8f4ac9d2521eb9ea6f0a6f9ef5f6d02cd1aeead02b00a5e5f155cc128bb3d54c3d5b189e3d8068b4
    HEAD_REF master
    PATCHES
        fix-pc-and-config.patch
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSW_BUILD=OFF
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
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
