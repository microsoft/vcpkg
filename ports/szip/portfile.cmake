set(SZIP_VERSION "2.1.1")
vcpkg_download_distfile(ARCHIVE
    URLS "https://support.hdfgroup.org/ftp/lib-external/szip/${SZIP_VERSION}/src/szip-${SZIP_VERSION}.tar.gz"
    FILENAME "szip-${SZIP_VERSION}.tar.gz"
    SHA512 ada6406efb096cd8a2daf8f9217fe9111a96dcae87e29d1c31f58ddd2ad2aa7bac03f23c7205dc9360f3b62d259461759330c7189ef0c2fe559704b1ea9d40dd
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF szip-${SZIP_VERSION}
    PATCHES
        fix-linkage-config.patch
        mingw-lib-names.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DSZIP_INSTALL_DATA_DIR=share/szip/data
        -DSZIP_INSTALL_CMAKE_DIR=share/szip
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/szip_adpt.h"
        "\n#ifdef SZ_BUILT_AS_DYNAMIC_LIB"
        "\n#if 1 // SZ_BUILT_AS_DYNAMIC_LIB")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    set(SZIP_LIB_RELEASE  "-lszip")
    set(SZIP_LIB_DEBUG    "-lszip_debug")
    set(SZIP_LIBS_PRIVATE "-lm")
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(SZIP_LIB_RELEASE  "-llibszip")
    set(SZIP_LIB_DEBUG    "-llibszip_D")
    set(SZIP_LIBS_PRIVATE "")
else()    
    set(SZIP_LIB_RELEASE  "-lszip")
    set(SZIP_LIB_DEBUG    "-lszip_D")
    set(SZIP_LIBS_PRIVATE "")
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(SZIP_LINKAGE_FLAGS "-DSZ_BUILT_AS_DYNAMIC_LIB=1")
else()
    set(SZIP_LINKAGE_FLAGS "")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib")
    set(SZIP_LIB "${SZIP_LIB_RELEASE}")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/szip.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/szip.pc" @ONLY)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib")
    set(SZIP_LIB "${SZIP_LIB_DEBUG}")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/szip.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/szip.pc" @ONLY)
endif()
vcpkg_fixup_pkgconfig()

file(RENAME "${CURRENT_PACKAGES_DIR}/share/szip/data/COPYING" "${CURRENT_PACKAGES_DIR}/share/szip/copyright")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
