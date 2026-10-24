vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nevergiveupcpp/obfuscxx
    REF v${VERSION}
    SHA512 9a59bcfd8eec47cb3c02d6e063221b3f7896bf49b8f64ff10ccb727286722d658b82dafc32be25e1b6fe1167a13e91381023c6f0712e7d0b2be8d9439f427790
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/obfuscxx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
