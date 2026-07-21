vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO devernay/cminpack
    REF "v${VERSION}"
    SHA512 900416128b093e4563d1d9f2827b79b61b640a24c9adb21473822008b3a4e377b9a14813697015af0b679d18634d177dfbf529dcaf5e1da40367f978dfda9537
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
