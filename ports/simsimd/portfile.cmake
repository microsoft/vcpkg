vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/SimSIMD
    REF "v${VERSION}"
    SHA512 de601eb1f7f5002d5223e8ec7fad88ded8d2c01806832ff2f610364e120c177b23c49ce144f21a7106e813b3592e2242a92613c74e9069c4d77d07e6cf36fec1
    HEAD_REF main
    PATCHES
        export-target.patch
        force-c17-on-msvc.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSIMSIMD_BUILD_TESTS=OFF
        -DSIMSIMD_BUILD_BENCHMARKS=OFF
        "-DSIMSIMD_BUILD_SHARED=${BUILD_SHARED}"
)

vcpkg_cmake_install()

if(BUILD_SHARED)
    vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-simsimd)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
