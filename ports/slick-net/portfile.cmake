vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-net
    REF "v${VERSION}"
    SHA512 246c12d331063849943ae6a0c988fddc8b5ad4110a1fede0c361455d06148fe7587dbd0b8233b901f12c9d0279147846cab90cf99e275e84823fca77c921f5f6
    HEAD_REF main
    PATCHES
        slick-dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_NET_TESTS=OFF
        -DBUILD_SLICK_NET_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME slick-net CONFIG_PATH share/slick-net)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
