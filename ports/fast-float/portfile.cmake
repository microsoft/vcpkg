vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fastfloat/fast_float
    REF "v${VERSION}"
    SHA512 a4bc2d11af67527421190bef07eef9dfca63efae6be1800f33a2419cb77031b0128ef9199b9909d01a76d72cdba56f79c6856a900c4cc7e7c75745d980f61340
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
