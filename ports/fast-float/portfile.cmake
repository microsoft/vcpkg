vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fastfloat/fast_float
    REF "v${VERSION}"
    SHA512 5c945facb30d7bfdf1d4f9fae4c53ae66e7f81e12fa0279ebcbc660e02cc093b28a3d1a2fe36b152bbf166c475dfbea57f30c313b00795974af9cb828ba41e4b
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
