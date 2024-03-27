vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nghttp2/nghttp2
    REF "v${VERSION}"
    SHA512 1526418b0cf8e065f00589c5abd0b4ebd32a3128fbedd7c1f8fc9a76b8b2ad9713a8f4b056d29fce454559fe9227392c59dcdffaa665249df94a1fcf85fcfc53
    HEAD_REF master
    PATCHES
        no-tests.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" ENABLE_STATIC_CRT)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_LIB_ONLY=ON
        -DENABLE_DOC=OFF
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
