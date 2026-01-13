vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-net
    REF "v${VERSION}"
    SHA512 2cfceabe3b4828f73506a607b163bdffa2ceec42d017bf1e060a3787f150d8e6dbd32699dccacb1effc329afbdc7c8e8314aa1f32f07fe20088b3cf9a1bb76b3
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
