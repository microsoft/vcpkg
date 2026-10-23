vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nevergiveupcpp/obfuscxx
    REF v${VERSION}
    SHA512 bc49c1c76d0d67f77e83c647b333cc2dff5632f51e6a373a63fe657f0c41245803d9d87562312232971a3711d83475bd830b4803e838844ee94632e2811a3c20
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/obfuscxx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
