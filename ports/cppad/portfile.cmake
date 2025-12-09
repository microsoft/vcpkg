vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CppAD
    REF "${VERSION}"
    SHA512 c94637d1859a8f3ac2ac3064d8f9f0baefefe8da6d4534bfa6a1602d610844bb3838bd9a2fcaf8ae1cce5dc2a2adb5e7eacaeccf006d746552eb2ff3ca75494a
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
