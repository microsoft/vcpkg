vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nghttp2/nghttp2
    REF "v${VERSION}"
    SHA512 debb43ad331c1a1e8a1591e9aab21a0e5f7a03372a845ee67f32307863aed5acf9d87feb4ca037158452c7482b59ce3e2a113992d5d696c8bfd7131bb02b38b1
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" ENABLE_STATIC_CRT)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_LIB_ONLY=ON
        -DENABLE_DOC=OFF
        -DBUILD_TESTING=OFF
        "-DENABLE_STATIC_CRT=${ENABLE_STATIC_CRT}"
        "-DBUILD_STATIC_LIBS=${ENABLE_STATIC_LIB}"
        -DCMAKE_DISABLE_FIND_PACKAGE_Python3=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenSSL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libngtcp2=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libngtcp2_crypto_quictls=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libnghttp3=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Systemd=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Jansson=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libevent=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_LibXml2=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Jemalloc=ON
    MAYBE_UNUSED_VARIABLES
        ENABLE_STATIC_CRT
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
    "${CURRENT_PACKAGES_DIR}/lib/cmake"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(APPEND "${CURRENT_PACKAGES_DIR}/include/nghttp2/nghttp2ver.h" [[
#ifndef NGHTTP2_STATICLIB
#  define NGHTTP2_STATICLIB
#endif
]])
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
