vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CppAD
    REF "${VERSION}"
    SHA512 abe9dd9a971f8d154990d54c1f798c8cab6bf90d016bb288efbcb23a14331897762610295658eec04fb50e5c13b05f4bb6b50a4647d6f0468eb94833dc3400d2
    HEAD_REF master
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" cppad_static_lib)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -Dcppad_static_lib=${cppad_static_lib}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/pkgconfig" # redundant
    # Remove empty dirs
    "${CURRENT_PACKAGES_DIR}/include/cppad/local/sweep/template"
    "${CURRENT_PACKAGES_DIR}/include/cppad/local/var_op/template"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
