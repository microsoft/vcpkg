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

file(READ "${SOURCE_PATH}/src/glad/include/glad/gl.h" _glad_header LIMIT 512)
string(REGEX MATCH "\\* SPDX-License-Identifier:[^\r\n]*" _glad_license "${_glad_header}")

file(READ "${SOURCE_PATH}/src/glad/include/KHR/khrplatform.h" _khr_header LIMIT 4096)
string(REGEX MATCH "/\\*([^*]|\\*+[^*/])*\\*+/" _khr_license "${_khr_header}")

file(WRITE "${CURRENT_BUILDTREES_DIR}/glad-license.txt"
     "${_glad_license}\n\n${_khr_license}\n")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/doc/license/gpl-2.0.txt" 
        "${SOURCE_PATH}/doc/license/gpl-3.0.txt"
        "${CURRENT_BUILDTREES_DIR}/glad-license.txt"
)
