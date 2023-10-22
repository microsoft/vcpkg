vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DanBloomberg/leptonica
    REF b667978e86c4bf74f7fdd75f833127d2de327550 # 1.83.1
    SHA512 fe4ea74aea024a4e522a5f985e51c5b110b5b4a3b3086e6fa7204129caf09b842f85041c386ee9bf2e878034ac2ebd2506396063771b677e931296ec6d76490b
    HEAD_REF master
    PATCHES
        fix-build-and-pkgconfig.patch # See https://github.com/DanBloomberg/leptonica/pull/664 and https://github.com/DanBloomberg/leptonica/pull/662
        private.patch # See https://github.com/DanBloomberg/leptonica/pull/666
        webp.patch # See https://github.com/DanBloomberg/leptonica/pull/667
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

file(INSTALL "${SOURCE_PATH}/leptonica-license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
