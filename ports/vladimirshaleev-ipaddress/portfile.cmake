vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vladimirshaleev/ipaddress
    REF "v${VERSION}"
    SHA512 5f6bff9ae836b7a4f7689fff05b9443c034a32fddc455c99e8e911a07a7e26078eb424e57df82a46da6af51bd62169e7e174dde6c6bfb7064e3369e81ad1365f
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
