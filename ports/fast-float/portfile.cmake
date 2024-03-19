vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fastfloat/fast_float
    REF "v${VERSION}"
    SHA512 32841b657014a093374ad98932898970f5b2e32cdaecfd47c7a77899445578090642e335a04ce04177857c5ff4411d76f3866cc62f2b00391290291d0d16a40e
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
