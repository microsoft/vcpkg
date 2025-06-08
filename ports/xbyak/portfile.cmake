string(REGEX REPLACE "^([0-9]+)[.]([1-9])\$" "\\1.0\\2" VERSION_STR "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO herumi/xbyak
    REF "v${VERSION_STR}"
    SHA512 d3ea24133c4e51f2245f15f49ba2039316e757605e2c73a8fcd032725bcb3a1d44fa0370022a11999691e86c0d1d93f424ecbf5d9b4e38a68dd0395a4a81f70a
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
