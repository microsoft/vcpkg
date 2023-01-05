if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # no exports
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CoinUtils
    REF "releases/${VERSION}"
    SHA512 47759e6ff85541c77a5447b1a3d46870f0704c2a508b946e07db76a06f1874cfd838100965c959bb32c85d6c5fe8a54702e911dde437f9c0116a99b55c98c31e
    PATCHES
        autotools.patch
        pkgconfig.patch
)

vcpkg_replace_string("${SOURCE_PATH}/CoinUtils/configure" "-lz" "")
vcpkg_replace_string("${SOURCE_PATH}/CoinUtils/configure" "-lbz2" "")

x_vcpkg_pkgconfig_get_modules(PREFIX ZLIB MODULES zlib LIBRARIES)
x_vcpkg_pkgconfig_get_modules(PREFIX BZIP MODULES bzip2 LIBRARIES)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}/CoinUtils"
    # AUTOCONFIG # needs more coin build tools
    NO_ADDITIONAL_PATHS
    OPTIONS
        --without-blas
        --without-lapack
        --without-glpk
        --without-sample
        --without-netlib
        ac_cv_prog_coin_have_doxygen=no
    OPTIONS_RELEASE
        "LIBS=${BZIP_LIBRARIES_RELEASE} ${ZLIB_LIBRARIES_RELEASE}"
    OPTIONS_DEBUG
        "LIBS=${BZIP_LIBRARIES_DEBUG} ${ZLIB_LIBRARIES_DEBUG}"
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

# vcpkg backward compatibility
configure_file("${CMAKE_CURRENT_LIST_DIR}/CoinUtilsConfig.cmake" "${CURRENT_PACKAGES_DIR}/share/coinutils/CoinUtilsConfig.cmake" @ONLY)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(RENAME "${CURRENT_PACKAGES_DIR}/share/coinutils/LICENSE" "${CURRENT_PACKAGES_DIR}/share/coinutils/copyright")
