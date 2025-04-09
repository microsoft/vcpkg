vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fastfloat/fast_float
    REF "v${VERSION}"
    SHA512 0475d4a9100fda4cf0ba3a5f90090d2b86f4a472dbc125db57101b75555a05148965432d8258dd2a0cdffe97c10b27efe45baf9a8fe129f71d7a58b0dc705b4e
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFASTFLOAT_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME FastFloat CONFIG_PATH share/cmake/FastFloat)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-APACHE" "${SOURCE_PATH}/LICENSE-BOOST" "${SOURCE_PATH}/LICENSE-MIT")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
