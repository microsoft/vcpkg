vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CoinUtils
    REF f709081c9b57cc2dd32579d804b30689ca789982 # releases/2.11.4
    SHA512 1c2e7f796524d67d87253bc7938c1a6db3c8266acec6b6399aeb83c0fb253b77507e6b5e84f16b0b8e40098aef94676499f396d1c7f653b1e04cbadca7620185
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}/CoinUtils"
    NO_ADDITIONAL_PATHS
    OPTIONS
        --without-blas
        --without-lapack
        --without-glpk
        --without-sample
        --without-netlib
        ac_cv_prog_coin_have_doxygen=no
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

# vcpkg backward compatibility
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/CoinUtilsConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/coinutils" RENAME CoinUtilsConfig.cmake)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/coinutils" RENAME copyright)
