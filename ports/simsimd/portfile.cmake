vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/SimSIMD
    REF "v${VERSION}"
    SHA512 4774141df1f70e455ca09b2b9d3adffe6b8b9fbecd3ae28c65170fd006ff38622b1fd8b3716012d883a9cf8625e1bfbf5209c35a0b2f6ee39a9feb442582635c
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
