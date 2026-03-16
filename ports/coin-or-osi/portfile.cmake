vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Osi
    REF releases/0.108.12
    SHA512 9f8f9da4d6e309530219d1b077a08d0f7e24f2bc36286667a412967f4f54d2df66b7dd7322328ed821ff1ab5211efc8eafaf29ef78293a7f8e6fab7cca09f870
)

set(OSI_SOURCE_PATH "${SOURCE_PATH}/Osi")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string(
        "${OSI_SOURCE_PATH}/Makefile.in"
        "PKG_CONFIG_PATH=@COIN_PKG_CONFIG_PATH@:$(DESTDIR)$(pkgconfiglibdir)"
        "PKG_CONFIG_PATH=$(DESTDIR)$(pkgconfiglibdir)"
    )
    # Avoid GCC-specific autoconf probes that assume a GNU compiler when
    # running configure under MSYS with MSVC. Preseed autoconf cache to
    # prevent detection paths that emit 'choke me' probes and fail on cl.exe.
    set(ENV{ac_cv_c_compiler_gnu} "no")
    set(ENV{ac_cv_cxx_compiler_gnu} "no")
endif()

file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${OSI_SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${OSI_SOURCE_PATH}/BuildTools\"")

vcpkg_configure_make(
    SOURCE_PATH "${OSI_SOURCE_PATH}"
    NO_ADDITIONAL_PATHS
    OPTIONS
        --with-glpk
        --with-lapack
        --with-coinutils
        --without-netlib
        --without-sample
        --without-gurobi
        --without-xpress
        --without-cplex
        --without-soplex
        --enable-relocatable
        --disable-readline
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${OSI_SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
