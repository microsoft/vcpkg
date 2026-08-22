vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO devernay/cminpack
    REF "v${VERSION}"
    SHA512 3a3879cd396b9a6665eae2edd6976ab465173881341de350f77c4af9cee73f6d77d5eaf60a5666674b50181031aae661e9711e9dbaa9e20f90e21b4ef91151e7
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
