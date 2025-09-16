vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mzying2001/sw
    REF ${VERSION}
    SHA512 47953746b8e518fb4baf1f6b17feb4dcefeb8d67ce62a2431ba3dd528680326518ce0859ce42e71fcf0e7c8260f920bb9d30878a28499521fe1ebf861a6c3898
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/sw
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME sw
    CONFIG_PATH share/mzying2001-sw
)

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
