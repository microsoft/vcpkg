include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JuliaLang/utf8proc
    REF v2.1.0
    SHA512 72b7f377fa6a62018d3eeab8723a27e25db3d1f794ae0bf21fff62ec1a7439bec52e7c93d2a00c218de6ff518097fb4a7a87c56e61ba8c98e689aa8f7171c812)

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-buildsystem.patch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${CURRENT_PACKAGES_DIR}/include/utf8proc.h UTF8PROC_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    string(REPLACE "defined UTF8PROC_SHARED" "0" UTF8PROC_H "${UTF8PROC_H}")
else()
    string(REPLACE "defined UTF8PROC_SHARED" "1" UTF8PROC_H "${UTF8PROC_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/utf8proc.h "${UTF8PROC_H}")

file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/utf8proc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/utf8proc/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/utf8proc/copyright)
