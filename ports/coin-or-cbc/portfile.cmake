vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Cbc
    REF releases/2.10.13
    SHA512 31a35e4b30181892c34065606b036702cfa5f9ba31589aa092a2da7293ba1c528ead3fa9aa9752470103b4cbe3609ef6fa1b89b1890534f1be10ad2bb60ac6e9
    PATCHES
        disable_glpk.patch
)

set(CBC_SOURCE_PATH "${SOURCE_PATH}/Cbc")

file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${SOURCE_PATH}/BuildTools\"")

if(VCPKG_TARGET_IS_WINDOWS)
    # Seed autoconf cache to skip GNU-compiler-specific probes when
    # configure runs under MSYS with MSVC. This avoids failing conftests
    # that are incompatible with cl.exe.
    set(ENV{ac_cv_c_compiler_gnu} "no")
    set(ENV{ac_cv_cxx_compiler_gnu} "no")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${CBC_SOURCE_PATH}"
    DEFAULT_OPTIONS_EXCLUDE "(--docdir=.*|--datarootdir=.*)"
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

vcpkg_make_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${CBC_SOURCE_PATH}/LICENSE")
