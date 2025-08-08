vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vladimirshaleev/ipaddress
    REF "v${VERSION}"
    SHA512 cc6b2e6dc72a8ac7d1c847e87294381026a584388a53a4d2583c04050e30b152b4b740dca3e809ae3541c380590553ec0934ff3e3b15bd0ba3ac297b5de30fb7
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
