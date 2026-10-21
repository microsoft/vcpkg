vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/SimSIMD
    REF "v${VERSION}"
    SHA512 8707d435d7f525e0ce562b01a151d814e38396d60b208d4676235ce0f356c30b22c94187ff419ad51cd43f3eb84ab8f952afe1e6b5c63fdb3daf87c2ef402bb6
    HEAD_REF main
    PATCHES
        export-target.patch
        force-c17-on-msvc.patch
        support-msvc.patch
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
