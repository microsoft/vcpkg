vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO williamh/dotconf
    REF ed5c5a1707ed55b45904f875f6b25ce9076f4fa6
    SHA512 06cd30eda123839e73793f397a9393d975968584ba15773f63eb984650c86bcbd7ceb0d20421a02e8f79a9c7b9a0ffd3c6f4dcc24eec613a3bf1b1e270df4bdd
    HEAD_REF master
    PATCHES
        subdirs.patch
        no-undefined.patch
)
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    DETERMINE_BUILD_TRIPLET
    OPTIONS
        ac_cv_func_malloc_0_nonnull=yes
        ac_cv_func_realloc_0_nonnull=yes
        ac_cv_func_strtod=yes
        WARNING_CFLAGS=
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
