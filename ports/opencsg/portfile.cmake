vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

string(REPLACE "." "-" VERSION_CSG "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO floriankirsch/OpenCSG
    REF "opencsg-${VERSION_CSG}-release"
    SHA512 ded016e6340b2dca479765bd638d353b1c4605cf7b579ab412cf8d789d56ce307a86576fc45307f87c7ea756bb9aff5db25c8a819352058ce4f7cf3e24056a07
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
