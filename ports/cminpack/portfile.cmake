vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO devernay/cminpack
    REF "v${VERSION}"
    SHA512 4a93ece7365e3ac9e9957b2c7ac1d0112314a0602eeaf312b78d7fdebc2208319f304e2fed140aa38fb6e179a9faef079e09b2f605fe0753b12751a3812a742b
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DUSE_BLAS=OFF
        -DBUILD_EXAMPLES_FORTRAN=OFF
        -DUSE_LAPACK=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cminpack-1/cminpack.h" [[!defined(CMINPACK_NO_DLL)]] 0)
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/CopyrightMINPACK.txt")
