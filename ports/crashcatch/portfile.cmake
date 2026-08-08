set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO keithpotz/CrashCatch
    REF "v${VERSION}"
    SHA512 1f7b8a75673abf74ee417fbc679bb293a04dc48f1c4a17fd69db0b7e260a30575564c4f406d98ab37478a9515b46cdc7b044e3050462a1b1384c0f95019b40da
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
