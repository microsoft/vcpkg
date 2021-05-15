vcpkg_download_distfile(ARCHIVE
    URLS "https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz"
    FILENAME "szip-2.1.1.tar.gz"
    SHA512 ada6406efb096cd8a2daf8f9217fe9111a96dcae87e29d1c31f58ddd2ad2aa7bac03f23c7205dc9360f3b62d259461759330c7189ef0c2fe559704b1ea9d40dd
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF szip-2.1.1
    PATCHES
        fix-linkage-config.patch
        mingw-lib-names.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSZIP_INSTALL_DATA_DIR=share/szip/data
        -DSZIP_INSTALL_CMAKE_DIR=share/szip
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/szip_adpt.h"
        "\n#ifdef SZ_BUILT_AS_DYNAMIC_LIB"
        "\n#ifndef SZ_BUILT_AS_DYNAMIC_LIB\n#define SZ_BUILT_AS_DYNAMIC_LIB 1\n#endif\n#ifdef SZ_BUILT_AS_DYNAMIC_LIB")
endif()

file(RENAME ${CURRENT_PACKAGES_DIR}/share/szip/data/COPYING ${CURRENT_PACKAGES_DIR}/share/szip/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
