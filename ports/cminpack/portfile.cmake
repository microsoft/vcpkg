# Must be removed on next release
vcpkg_download_distfile(DLLEXPORT_PATCH
    URLS https://github.com/devernay/cminpack/commit/0d40c5359674448aa6f78accaddca1d79befff1f.patch?full_index=1
    FILENAME devernay-cminpack-pr-50-dllexport.patch
    SHA512 558c21c4d43ff64a38945643810eafaee46c5f61c0e2a98931f9ba2283cf46e234a74f12ce6db4e64289de58f8da190af936f847f42636fd812fdf82ff733763
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO devernay/cminpack
    REF v1.3.8
    SHA512 0cab275074a31af69dbaf3ef6d41b20184c7cf9f33c78014a69ae7a022246fa79e7b4851341c6934ca1e749955b7e1096a40b4300a109ad64ebb1b2ea5d1d8ae
    PATCHES
        ${DLLEXPORT_PATCH}
)
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" [[ STRING "CMinpack]] [[) # ("CMinpack]])

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DCMINPACK_LIB_INSTALL_DIR=lib
        -DUSE_BLAS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cminpack-1/cminpack.h" [[!defined(CMINPACK_NO_DLL)]] 0)
endif()
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cminpack.pc" "-lcminpack" "-lcminpack_d")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cminpacks.pc" "-lcminpacks" "-lcminpacks_d")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cminpackld.pc")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cminpackld.pc" "-lcminpackld" "-lcminpackld_d")
    endif()
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/CopyrightMINPACK.txt")
