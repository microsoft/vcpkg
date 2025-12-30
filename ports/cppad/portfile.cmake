vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CppAD
    REF "${VERSION}"
    SHA512 f2dffaeaaf46dcd051a3354478c7ba61ed6a3538cdcc39c066fd9eb22ef58f0cde30079595e9db273d6484a31c8f73c84061ac7f5a5028f920ec74ef26c8e7c1
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -Dcppad_prefix=${CURRENT_PACKAGES_DIR}
    OPTIONS_RELEASE
        -Dcmake_install_libdirs=lib
    OPTIONS_DEBUG
        -Dcmake_install_libdirs=debug/lib
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/share/pkgconfig"
    # Remove empty dirs
    "${CURRENT_PACKAGES_DIR}/include/cppad/local/sweep/template"
    "${CURRENT_PACKAGES_DIR}/include/cppad/local/var_op/template"
)

# Add the copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
