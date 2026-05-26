vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO caomengxuan666/cxxmcp
    REF "v${VERSION}"
    SHA512 e40c49977533fa0d4cef3b5d6eaef5f25bf71743f38942f993fcf19dac3dbf199d0b656d1b9fac2e2d13dfc5b887e6028845d4080cef8a837c133aa77dd62de6
    HEAD_REF master
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCXXMCP_BUILD_SDK=ON
        -DCXXMCP_BUILD_RUNTIME=OFF
        -DCXXMCP_BUILD_APP=OFF
        -DCXXMCP_BUILD_GATEWAY=OFF
        -DCXXMCP_BUILD_CLI=OFF
        -DCXXMCP_BUILD_EXAMPLES=OFF
        -DCXXMCP_BUILD_TESTS=OFF
        -DCXXMCP_BUILD_DOCS=OFF
        -DCXXMCP_USE_SYSTEM_DEPS=ON
        -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME cxxmcp CONFIG_PATH lib/cmake/cxxmcp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
