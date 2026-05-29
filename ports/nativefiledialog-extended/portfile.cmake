vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO btzy/nativefiledialog-extended
    REF v${VERSION}
    SHA512 1f2e17dd9ee5b416dfe1362b6eac6499c83c527a83478361769420f1d29bf21e0a81e4b6d45255703aba9be61c8379f7745fe182d74687a9c4f3309bd4fdf09e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNFD_BUILD_TESTS=OFF
        -DNFD_PORTAL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME nfd CONFIG_PATH lib/cmake/nfd)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
