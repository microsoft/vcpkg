string(REGEX REPLACE "^([0-9]+)[.]([1-9])\$" "\\1.0\\2" VERSION_STR "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO herumi/xbyak
    REF "v${VERSION_STR}"
    SHA512 b5ba0be564ac042567caafe472f5d56b35562e6a6a8357424202cbba611b6cf7665bc8b0b25899e50f54a72b05f3504e8baf6317f52cb409aca0813a4aac1bc5
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/xbyak")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
