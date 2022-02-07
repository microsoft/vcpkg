vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nghttp2/nghttp2
    REF 7af0c508be9cbec407268e2f546f597d268c104e # v1.46.0
    SHA512 e25e8a43d0f9523f654d9136c2b9db30cfa5e8086da3fe3e9bcf68ff8c034383550ca17d89d31cd14e23b5886a0a948d777b4e182d0a042ccfe9a8083410de93
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" ENABLE_STATIC_CRT)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_LIB_ONLY=ON
        -DENABLE_ASIO_LIB=OFF
        "-DENABLE_STATIC_CRT=${ENABLE_STATIC_CRT}"
        "-DENABLE_STATIC_LIB=${ENABLE_STATIC_LIB}"
        "-DENABLE_SHARED_LIB=${ENABLE_SHARED_LIB}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
    file(APPEND "${CURRENT_PACKAGES_DIR}/include/nghttp2/nghttp2ver.h" [[
#ifndef NGHTTP2_STATICLIB
#  define NGHTTP2_STATICLIB
#endif
]])
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
