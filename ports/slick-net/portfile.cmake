vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-net
    REF "v${VERSION}"
    SHA512 d0177beb2fd3721b88529226521001edbf8681b7f3e16e22259423ccfdd337eb2e145bef0ef6c6a88609a6ba49c70103cf9d2c01afc57987bd24da61e728a2e0
    HEAD_REF main
    PATCHES
        slick-queue.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_NET_TESTS=OFF
        -DBUILD_SLICK_NET_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME slick-net CONFIG_PATH share/slick-net)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
