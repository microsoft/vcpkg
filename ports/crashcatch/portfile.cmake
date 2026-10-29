set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO keithpotz/CrashCatch
    REF "v${VERSION}"
    SHA512 97b5397b358d3f36c00209785f01a00d5119600267343f6d6bcbd8c4282e46d0c5709f420734e5a54009fe239f5e954ad489f4e05bd506111cc921aac851fd12
    HEAD_REF main
    PATCHES
        fix-disable-examples-tests.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCRASHCATCH_BUILD_EXAMPLES=OFF
        -DCRASHCATCH_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/CrashCatch")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
