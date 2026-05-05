vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-net
    REF "v${VERSION}"
    SHA512 9779ae452e26f8a60c94eddd8102e1f134b3d9699e2645c6e4dff2edc7c488fda0482e9abdcd79472db77ac6cdcb994103c8e05d4f5cd74af088c3f9b5d031e3
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
