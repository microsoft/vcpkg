vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/NumKong
    REF "v${VERSION}"
    SHA512 67673236db6f0e7b022323841dcf6a06dddbb695ec2f24d5f1a4cff9d2cf899b611d20b0c2ca9ec11fc87774a5f50c2f0ee4b6365a50fe094f2b1d56f68cd656
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
