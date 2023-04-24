vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bombela/backward-cpp
    REF "v${VERSION}"
    SHA512 db0256a54819952ff1d92e05d6ab81fe979d4826ebb6651b6b08c30e7a0091879dfeff33d81f9599462152ce68e61e2c8c42bf039129bc6b28d1e68b1eab039b
    HEAD_REF master
    PATCHES
        include-dir.diff
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME backward CONFIG_PATH lib/backward)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
