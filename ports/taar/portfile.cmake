vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rjahanbakhshi/boost.taar
    REF "v${VERSION}"
    SHA512 b512e0f3c11e95ea6e0d9aa197ef2d380ba51fe2ea4a712bad18e0c5740c9470f6038a0bfcf695f137aa82e181c6479c30388056c8dfc740fee7f02542cfdd75
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBOOST_TAAR_BUILD_TESTS=OFF
        -DBOOST_TAAR_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME boost-taar CONFIG_PATH share/cmake/boost-taar)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
