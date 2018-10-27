# libarchive uses winapi functions not available in WindowsStore
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are not supported.")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libarchive/libarchive
    REF v3.3.3
    SHA512 10063764b610c0c966ba0177cac0d2cb781e297a45545cc8a587741513089af26f40769670894c86e7985b73c47e9cb985253bc3bef3a12fa83fe2a6a30acb6d
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-buildsystem.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-dependencies.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-lz4.patch
        ${CMAKE_CURRENT_LIST_DIR}/no-werror.patch
)

set(BUILD_libarchive_bzip2 OFF)
if("bzip2" IN_LIST FEATURES)
  set(BUILD_libarchive_bzip2 ON)
endif()

set(BUILD_libarchive_libxml2 OFF)
if("libxml2" IN_LIST FEATURES)
  set(BUILD_libarchive_libxml2 ON)
endif()
set(BUILD_libarchive_libxml2 OFF)

set(BUILD_libarchive_lz4 OFF)
if("lz4" IN_LIST FEATURES)
  set(BUILD_libarchive_lz4 ON)
endif()

set(BUILD_libarchive_lzma OFF)
if("lzma" IN_LIST FEATURES)
  set(BUILD_libarchive_lzma ON)
endif()

set(BUILD_libarchive_lzo OFF)
if("lzo" IN_LIST FEATURES)
  set(BUILD_libarchive_lzo ON)
endif()

set(BUILD_libarchive_openssl OFF)
if("openssl" IN_LIST FEATURES)
  set(BUILD_libarchive_openssl ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_BZip2=${BUILD_libarchive_bzip2}
        -DENABLE_LIBXML2=${BUILD_libarchive_libxml2}
        -DENABLE_LZ4=${BUILD_libarchive_lz4}
        -DENABLE_LZMA=${BUILD_libarchive_lzma}
        -DENABLE_LZO=${BUILD_libarchive_lzo}
        -DENABLE_OPENSSL=${BUILD_libarchive_openssl}
        -DENABLE_PCREPOSIX=OFF
        -DENABLE_NETTLE=OFF
        -DENABLE_EXPAT=OFF
        -DENABLE_LibGCC=OFF
        -DENABLE_CNG=OFF
        -DENABLE_TAR=OFF
        -DENABLE_CPIO=OFF
        -DENABLE_CAT=OFF
        -DENABLE_XATTR=OFF
        -DENABLE_ACL=OFF
        -DENABLE_TEST=OFF
        -DENABLE_ICONV=OFF
        -DPOSIX_REGEX_LIB=NONE)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
foreach(HEADER ${CURRENT_PACKAGES_DIR}/include/archive.h ${CURRENT_PACKAGES_DIR}/include/archive_entry.h)
    file(READ ${HEADER} CONTENTS)
    string(REPLACE "(!defined LIBARCHIVE_STATIC)" "0" CONTENTS "${CONTENTS}")
    file(WRITE ${HEADER} "${CONTENTS}")
endforeach()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libarchive)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libarchive/COPYING ${CURRENT_PACKAGES_DIR}/share/libarchive/copyright)
