cmake_minimum_required(VERSION 3.13)

if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h")
  message(WARNING "Can't build libressl if openssl is installed. Please remove openssl, and try install libressl again if you need it. Build will continue since libressl is a subset of openssl")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
  return()
endif()

include(vcpkg_common_functions)

set(LIBRESSL_VERSION 2.9.1)
set(LIBRESSL_HASH 7051911e566bb093c48a70da72c9981b870e3bf49a167ba6c934eece873084cc41221fbe3cd0c8baba268d0484070df7164e4b937854e716337540a87c214354)

vcpkg_download_distfile(
    LIBRESSL_SOURCE_ARCHIVE
    URLS https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/${PORT}-${LIBRESSL_VERSION}.tar.gz
    FILENAME ${PORT}-${LIBRESSL_VERSION}.tar.gz
    SHA512 ${LIBRESSL_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${LIBRESSL_SOURCE_ARCHIVE}"
    REF ${LIBRESSL_VERSION}
    PATCHES
        0001-enable-ocspcheck-on-msvc.patch
        0002-suppress-msvc-warnings.patch
)

set(LIBRESSL_APPS OFF)
if("tools" IN_LIST FEATURES)
    set(LIBRESSL_APPS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLIBRESSL_APPS=${LIBRESSL_APPS}
        -DLIBRESSL_TESTS=OFF
    OPTIONS_DEBUG
        -DLIBRESSL_APPS=OFF
)

vcpkg_install_cmake()

if(LIBRESSL_APPS)
    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
        set(EXECUTABLE_SUFFIX .exe)
    endif()
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/openssl")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/openssl${EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/openssl/openssl${EXECUTABLE_SUFFIX}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/ocspcheck${EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/openssl/ocspcheck${EXECUTABLE_SUFFIX}")
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/openssl")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/etc/ssl/certs"
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if((NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore) AND (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic"))
    file(GLOB_RECURSE LIBS "${CURRENT_PACKAGES_DIR}/*.lib")
    foreach(LIB ${LIBS})
        string(REGEX REPLACE "(.+)-[0-9]+\\.lib" "\\1.lib" LINK "${LIB}")
        execute_process(COMMAND "${CMAKE_COMMAND}" -E create_symlink "${LIB}" "${LINK}")
    endforeach()
endif()
