vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vladimirshaleev/ipaddress
    REF "v${VERSION}"
    SHA512 a8ab2dc8563ff08a5afbe6d2157502b26a5d13f29d00ab3354b812ad4cb9e35cdc89cb26e4920929ced7d063ae2ad5aa79d30a4623409f65c76971ecbbcd5bfc
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIPADDRESS_BUILD_DOC=OFF
        -DIPADDRESS_BUILD_TESTS=OFF
        -DIPADDRESS_BUILD_BENCHMARK=OFF
        -DIPADDRESS_BUILD_PACKAGES=OFF
        -DIPADDRESS_ENABLE_CLANG_TIDY=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ipaddress CONFIG_PATH share/cmake/ipaddress)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
