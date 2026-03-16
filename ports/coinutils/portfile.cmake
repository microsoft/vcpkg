vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CoinUtils
    REF releases/2.11.13
    SHA512 4f31a22bb70c51d2a607dd685b9e804a5718d1ab67993dff86da25f4f6fe2e4173810522252703a439a0e1e7828b8ad42c5ca5ef97030d1760453f8f3155b7f5
)

set(COINUTILS_SOURCE_PATH "${SOURCE_PATH}/CoinUtils")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string(
        "${COINUTILS_SOURCE_PATH}/Makefile.in"
        "PKG_CONFIG_PATH=@COIN_PKG_CONFIG_PATH@:$(DESTDIR)$(pkgconfiglibdir)"
        "PKG_CONFIG_PATH=$(DESTDIR)$(pkgconfiglibdir)"
    )
    # Prevent autoconf from performing GCC-specific probes when running
    # under MSYS with MSVC. Seed autoconf cache to avoid 'choke me' test
    # code paths that don't compile with cl.exe.
    set(ENV{ac_cv_c_compiler_gnu} "no")
    set(ENV{ac_cv_cxx_compiler_gnu} "no")
endif()

file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${COINUTILS_SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${COINUTILS_SOURCE_PATH}/BuildTools\"")

#--enable-msvc
set(options "")
if("glpk" IN_LIST FEATURES)
    list(APPEND options "--with-glpk")
else()
    list(APPEND options "--without-glpk")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${COINUTILS_SOURCE_PATH}"
    NO_ADDITIONAL_PATHS
    OPTIONS
        ${options}
        --without-netlib
        --without-sample
        --without-asl
        #--enable-coinutils-threads  # only with -lrt
        #--enable-coinutils-bigindex  # only for x64
        --enable-relocatable
        --disable-readline
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${COINUTILS_SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/coinutils" RENAME copyright)

if(EXISTS "${COINUTILS_SOURCE_PATH}/m4")
    file(COPY "${COINUTILS_SOURCE_PATH}/m4" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()
