vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/SimSIMD
    REF "v${VERSION}"
    SHA512 d622feb2153365a71c0c4a8a7af52aba4cdf9984cd260773dc59d38d9e874bcce1f957fe573b487be619674d6ef2151357a7a61fc6d8358c740486973ad67676
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
