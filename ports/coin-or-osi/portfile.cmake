vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Osi
    REF 79167ab9a4487b5a1f88ec4fdfd4ed529a1c31ff 
    SHA512 405206d1a8e1f0adff8223ad4843251532dc954a6400f8566d826f93dd55741423185001f4d5a97b4d02ed39a9fe32ef063978d101c0a3eaa341a7c0dbce9765
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
