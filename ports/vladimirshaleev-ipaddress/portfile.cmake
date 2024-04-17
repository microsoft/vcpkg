vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vladimirshaleev/ipaddress
    REF "v${VERSION}"
    SHA512 dc8d37b5a28c80e6ddf4dfa0ffc6973b2625d20dc61cd56e77e1f2cfdc7d427937b73e2abb0d1d85cdfe54fc199fef4132c20fc01b1e91bab6a988650d6e9a6d
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
