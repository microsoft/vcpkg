vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/SimSIMD
    REF "v${VERSION}"
    SHA512 b4c0150d0a679f6ff5eb7d0a8816f713f9d72a4cbc5e230d9553584283deba2090d13ececddda22a8242d1923ca4f3771b3bea60e3dc40b77c546197d0d1ce6a
    HEAD_REF main
    PATCHES
        export-target.patch
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
