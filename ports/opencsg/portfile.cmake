vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

string(REPLACE "." "-" VERSION_CSG "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO floriankirsch/OpenCSG
    REF "opencsg-${VERSION_CSG}-release"
    SHA512 9c674553ff0bccd35b34475019f53f4dda900c4b26635e6f52871b81e974a9c6319891c1d42e387606ccb0a890dcbb286baa424ce240f78493ef6f920c0bcb3a
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
