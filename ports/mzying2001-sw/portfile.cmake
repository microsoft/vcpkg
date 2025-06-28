vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mzying2001/sw
    REF ${VERSION}
    SHA512 1e8e997ed0c6c95b7dbda92a81d87b488d0f7ba3ab251200b931fbdd4acd0140023aad52acdaa2394793ee31ebc164c322f285fdace082aafa4f904308d4eb42
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
