vcpkg_download_distfile(
    werror_patch
    URLS https://github.com/erincatto/Box2D/commit/0f2b0246f39594e93fcc8dde0fe0bb1b20b403f9.patch?full_index=1
    SHA512 debe1bae799909ad51a1a69d79843e1d4bfcd86257057de1c09c79479bd5e4714b9ae78e593f854868af568b459a24de29a369d04e6f280fcb233398e486bac3
    FILENAME erincatto-Box2D-0f2b024.diff
)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erincatto/Box2D
    REF v${VERSION}
    SHA512 85d67a0de92aecc61692d7a6f1a8c7e878cdd2a6457470f1a9be075dfc27fdcefb951ac689d95bb78a7b791d6586f794720af8417f55d7f66782b4c3c179210a
    HEAD_REF main
    PATCHES
        ${werror_patch}
        crt-linkage.diff
        libm.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBOX2D_SAMPLES=OFF
        -DBOX2D_BENCHMARKS=OFF
        -DBOX2D_DOCS=OFF
        -DBOX2D_PROFILE=OFF
        -DBOX2D_VALIDATE=OFF
        -DBOX2D_UNIT_TESTS=OFF
        -DBOX2D_COMPILE_WARNING_AS_ERROR=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/box2d)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/box2d/base.h" "defined( BOX2D_DLL )" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
