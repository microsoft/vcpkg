vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mzying2001/sw
    REF ${VERSION}
    SHA512 9879390d9b85010f0f93ff864f01879af6974f4370049bd3aeb7008c227ed140249f65eac40c0c485de0c8ae31cfeae3a919b7a31da8c8bca5cf844f23139f04
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/sw
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME sw
    CONFIG_PATH share/sw
)

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
