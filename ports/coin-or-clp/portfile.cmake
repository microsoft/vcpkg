vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Clp
    REF releases/1.17.11
    SHA512 212b5a928db66130d7c844c01e40bbecc4f9267944137ec9cfd3efb089f2c91c2113a0a593d4cf66ab3957df8c4cf6a701e10b33a637a7568deaef2253a746d9
)

set(CLP_SOURCE_PATH "${SOURCE_PATH}/Clp")

file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${CLP_SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${CLP_SOURCE_PATH}/BuildTools\"")

vcpkg_configure_make(
    SOURCE_PATH "${CLP_SOURCE_PATH}"
    AUTOCONFIG
    NO_ADDITIONAL_PATHS
    OPTIONS
      --with-coinutils
      --with-glpk
      --with-osi
      --without-ositests
      --without-sample
      --without-netlib
      --without-amd
      --without-cholmod
      --without-mumps
      --enable-relocatable
      --disable-readline
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CLP_SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
