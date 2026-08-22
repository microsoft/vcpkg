vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DanBloomberg/leptonica
    REF "${VERSION}"
    SHA512 2a1953dd0c962a05dac9bb30eac311896f414c658d976008b0c2d1b3b85ec25c5fd811be3f98a37f2131ded134799ea609a667fb1eaacf42d1aca9cc5cf1bd92
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
