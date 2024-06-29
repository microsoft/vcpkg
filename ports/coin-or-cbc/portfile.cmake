vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Cbc
    REF ca088df34881ef0d58124e53b3d70bfa73e92713
    SHA512 9df1242910a42a9b942fd25dbf8a80b6278d75641c93e1218b39695224cf88bdf9d1a2d27e637ebb068b1e8733267a0f16c69b4db9a480e3f6b9cd732afb2d7a
    PATCHES
        pkgconf_win.patch
        disable_glpk.patch
)

file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${SOURCE_PATH}/BuildTools\"")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    DETERMINE_BUILD_TRIPLET
    USE_WRAPPERS
    OPTIONS
        --with-coinutils
        --with-clp
        --with-cgl
        --with-osi
        --without-ositests
        --without-sample
        --without-netlib
        --without-miplib3
        --enable-relocatable
        --disable-readline
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
