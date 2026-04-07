vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

string(REPLACE "." "-" VERSION_CSG "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO floriankirsch/OpenCSG
    REF "opencsg-${VERSION_CSG}-release"
    SHA512 03b33dc1f2b04e94490fdcac2d1dc25ecd8608706f0510dc0c6c3b5e51f031c4f8dae5f29ee72e47c15b67cf13f3f2dd82777686260179b95d83086db44f6aea
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
