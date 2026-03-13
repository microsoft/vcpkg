vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Cgl
    REF releases/0.60.10
    SHA512 b422e9ad00d647602fa122a650264e77cefc25106a99cf4e101f117f9ee72c4256728faa9fa7d81f1ad9fd2461d147b9e771827b6121562e274812a13d5988b1
)

set(CGL_SOURCE_PATH "${SOURCE_PATH}/Cgl")

file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${CGL_SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${CGL_SOURCE_PATH}/BuildTools\"")

vcpkg_configure_make(
    SOURCE_PATH "${CGL_SOURCE_PATH}"
    NO_ADDITIONAL_PATHS
    OPTIONS
      --with-coinutils
      --with-osi
      # The rest will be pulled in via being available. 
      # Since there are no features in the other coin-or-* ports 
      # yet there is no need to control them here.
      --without-sample
      --without-netlib
      --enable-relocatable
      --disable-readline
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CGL_SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
