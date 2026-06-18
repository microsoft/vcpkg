vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jlblancoc/nanoflann
    REF "${VERSION}"
    SHA512 95c4e929c9e5accc99ac5f2927119ed3f8240729ed7695ed1fbe89ee96ba3498c1aa25164c57819d44f0f829a7c2b46c468932bb0bfb665bb01f60bf1bb9e02a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANOFLANN_BUILD_EXAMPLES=OFF
        -DNANOFLANN_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
