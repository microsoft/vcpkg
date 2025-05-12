string(REGEX REPLACE "^([0-9]+)[.]([1-9])\$" "\\1.0\\2" VERSION_STR "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO herumi/xbyak
    REF "v${VERSION_STR}"
    SHA512 d8bcf248b4506f09ee70431f6c38d0d2eb7c3dfa110cbe700e7ae689e0a640f77ec337aeafda93d0f4fd7e9139a8e46dbf1cb99dd4a576667d71b05992a618b8
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
