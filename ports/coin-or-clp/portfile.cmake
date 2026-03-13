vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Clp
    REF 5c9a9ee60e7c0bdd1e62c6b974484ddee5755bc8 # Parent revision of release, as the release commit is not part of the official repo
    SHA512 594ff9dbfb50c9c9bfed9b153170a555350178a710f4c5c2e64e854473372b1ffa1cc4dd47cfdf3e4866f7e3c6752d1d17a09d84efbac7793430bd89ebc286bc
    PATCHES
        dep.patch
)

file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${SOURCE_PATH}/BuildTools\"")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
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

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/coin-or/ClpModel.hpp" "\"glpk.h\"" "\"../glpk.h\"")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
