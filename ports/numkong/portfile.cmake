vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/NumKong
    REF "v${VERSION}"
    SHA512 990c270c75ea4226dd1672591f8d0162687e942188879d811940719df57b7c2f5696a4047a70f0898cf184b425739796400d94d5ee94d57f2e063867e7e91484
    HEAD_REF main
    PATCHES
        # https://github.com/ashvardanian/NumKong/pull/378
        export-target.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNK_BUILD_TEST=OFF
        -DNK_BUILD_SHARED_TEST=OFF
        -DNK_BUILD_BENCH=OFF
        -DNK_ENABLE_ASAN=OFF
        "-DNK_BUILD_SHARED=${BUILD_SHARED}"
)

vcpkg_cmake_install()

if(BUILD_SHARED)
    vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-numkong)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
else()
    # numkong is a header-only library when the library linkage is static.
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
