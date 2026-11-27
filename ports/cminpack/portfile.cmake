vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO devernay/cminpack
    REF "v${VERSION}"
    SHA512 cb2fb9538697d5e62216926c06391d5d9a91fe67f44cb92ac3bab6fee0be44fde312280e8c774b273c0a1698e9d4cdad8748e15fdf7d225025aa9e4cdf156a95
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
