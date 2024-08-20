vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Clp
    REF 5315ef2e93f5f532a600e16ab604ac439a416e59
    SHA512 78dc8f562e7c1bff3e86c81eda4eda9780a4075921bcdd2338191f37820699baee94eec86b6f63b1b27e5bca7346a2611d669a7cdf3e47e1c032b072ca10bdab
    PATCHES dep.patch
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
