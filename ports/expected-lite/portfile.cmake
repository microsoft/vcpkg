vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/expected-lite
    REF "v${VERSION}"
    SHA512 a5c2c3b8a2ad22938a2efaaa53fc110c0323e9c9cd384af1aaf74dc9f2e9d73451d9de1bfe6eb64546fb70853c006344bcedb09ccebbef6ea52fb10d857b1a45
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DEXPECTED_LITE_OPT_BUILD_TESTS=OFF
        -DEXPECTED_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/${PORT}
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
