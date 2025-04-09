vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Osi
    REF 2420bb864d039a03e11c579b0c9087adbdaa26db
    SHA512 27d501cb513a0570ad83247b6a8e7fc69cdbcd2cbec6c11aea0b5982627e76efa7ea6403e6d97419f6c984553434f088a748a7d8d54c1bf73cdbdfd5bef1f2b0
    PATCHES glpk.patch
)

file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${SOURCE_PATH}/BuildTools\"")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
