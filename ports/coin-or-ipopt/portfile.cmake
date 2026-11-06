vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Ipopt
    REF ec43e37a06054246764fb116e50e3e30c9ada089
    SHA512 f5b30e81b4a1a178e9a0e2b51b4832f07441b2c3e9a2aa61a6f07807f94185998e985fcf3c34d96fbfde78f07b69f2e0a0675e1e478a4e668da6da60521e0fd6
    HEAD_REF master
    PATCHES
        find-vcpkg-mumps.patch
)
  # --with-precision        floating-point precision to use: single or double
                          # (default)
  # --with-intsize          integer type to use: specify 32 for int or 64 for
                          # int64_t
file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${SOURCE_PATH}/BuildTools\"")

# Ipopt needs a sparse linear solver for the KKT system; LAPACK alone is dense
# only and leaves the solver unusable at run time. MUMPS is the only sparse
# solver Ipopt supports that is redistributable, so it is on by default. It is
# found through the mumps-solver port's unofficial-mumps-solver pkg-config module, which
# carries the library names and Fortran runtime for the triplet.
set(mumps_option "--without-mumps")
if("mumps" IN_LIST FEATURES)
    set(mumps_option "--with-mumps")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
      #--with-pardiso
      --without-spral
      #--without-wsmp
      --without-hsl
      --without-asl
      --with-lapack
      ${mumps_option}
      --enable-relocatable
      --disable-f77
      --disable-java
)

vcpkg_make_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
