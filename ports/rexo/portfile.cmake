vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO christophercrouzet/rexo
    REF "v${VERSION}"
    SHA512 fecb6b29a3396470c2f5174e74c6283b8c8b8b91294e4c0ed478ec4c896961bb3503a718d0e7fb5eec23aa0a2a80befa25e35b0d27eeab3708aa18d659968547
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DREXO_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Rexo)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/UNLICENSE")
