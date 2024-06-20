vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nghttp2/nghttp2-asio
    REF e877868abe06a83ed0a6ac6e245c07f6f20866b5
    SHA512 ed9112d8062dc624cb954c6b4366f79e1e4a8c814a12c9f428a3da882127895b6ea0ff82a3660469c2bef29e3dea906ad9127faa46df773e00ed93b8c7c31d9c
    PATCHES
        0001-Fix-exception-in-server.patch
        0002-Honor-BUILD_SHARED_LIBS.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" ENABLE_STATIC_CRT)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
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
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
