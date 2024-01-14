vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Cbc
    REF 6f83969e50b6f67c60654704c1f71f970c621a3b
    SHA512 f56b5806b2acffe7259410254640009f9b7a27713972d771b1083a05ca197a65715b007f42f0b8bf6e87b2a889e2889a7466222e0b06f01a4c5297cbaf455c4d
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
