vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fastfloat/fast_float
    REF "v${VERSION}"
    SHA512 794b6a99cd3b903df2ded95202873882317a47a34d88c4b9b30bb2f3b37eeb75645bb1a8b19715fe723186c57317c027ecdb399937744a1800fbd1d121ac6f12
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
