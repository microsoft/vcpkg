vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

string(REPLACE "." "_" release_tag "xmlsec_${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lsh123/xmlsec
    REF "${release_tag}"
    SHA512 c7b867edc23cb6cf08228f9737fc50e3bd08ac7baedc43e26d3cfd113ea54256ff357335b23aea7b5e49cd24809c3de9da1c9314eb5ab90727aa821530b72ef8
    HEAD_REF master
    PATCHES 
        pkgconfig_fixes.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DINSTALL_HEADERS_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-xmlsec)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/xmlsec/xmlsec.h"
    "ifdef XMLSEC_NO_SIZE_T"
    "if 1 //ifdef XMLSEC_NO_SIZE_T"
  )
endif()

# unofficial legacy usage
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/xmlsec-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/Copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
