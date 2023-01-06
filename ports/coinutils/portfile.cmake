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

# We cannot run autoreconf without providing extra coin-or build tools
# and the specific compatible version of autotools, cg.
# https://coin-or-tools.github.io/BuildTools/autotools#using-the-correct-version-of-the-autotools
# But we need to update key scripts for arm64-windows and uwp support.
set(gnu_config_revision f992bcc08219edb283d2ab31dd3871a4a0e8220e) # 2022-10-07
vcpkg_download_distfile(
    gnu_config_archive
    URLS https://git.savannah.gnu.org/cgit/config.git/snapshot/config-${gnu_config_revision}.tar.gz
    FILENAME "gnu-config-${gnu_config_revision}.tar.gz"
    SHA512 2fcce1b1a2b4d59080662ef52d4f32bb105266888a0c40479b9bd044e38f9b7c83ed4bddd32c7c64494f172f22107cc5477c54311039189622765cc55ba34db8
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH gnu_config_source
    ARCHIVE "${gnu_config_archive}"
    REF "${gnu_config_revision}"
)
file(INSTALL "${gnu_config_source}/config.guess"
             "${gnu_config_source}/config.sub"
    DESTINATION "${SOURCE_PATH}/CoinUtils"
)

x_vcpkg_pkgconfig_get_modules(PREFIX ZLIB MODULES zlib LIBRARIES)
x_vcpkg_pkgconfig_get_modules(PREFIX BZIP MODULES bzip2 LIBRARIES)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}/CoinUtils"
    DETERMINE_BUILD_TRIPLET
    NO_ADDITIONAL_PATHS
    USE_WRAPPERS
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
