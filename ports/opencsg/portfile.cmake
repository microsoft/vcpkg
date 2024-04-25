vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

string(REPLACE "." "-" VERSION_CSG "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO floriankirsch/OpenCSG
    REF "opencsg-${VERSION_CSG}-release"
    SHA512 531dda97fbbcfca9bd57eb2d62b34ed382788bafffff05aa4007cf6dd7093c478e6364020e58cda8adcc1bc45485c22e3a94dbc52916da6a8b418412ce7712c6
    HEAD_REF master
    PATCHES
        illegal_char.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/doc/license/gpl-2.0.txt" "${SOURCE_PATH}/doc/license/gpl-3.0.txt")
