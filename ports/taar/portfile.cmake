vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rjahanbakhshi/boost.taar
    REF "v${VERSION}"
    SHA512 d15af5ac39a18ef8011018a9c63dd6f97adb3598be30714669f42fdab812daf06a40f8ef88e38a2ac93abb843de96e0f7256dd7090094392d33cb347cb98dd29
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
