vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mzying2001/sw
    REF ${VERSION}
    SHA512 44d6bfc2f86cb0bfa9910b4fc5a168e165dcae78121e7ac55219b27abf0a1d77a291fab97d2772d4bca166df4a740d835bc05e7e76e443480e75c77470603cdd
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
