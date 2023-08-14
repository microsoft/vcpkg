vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Cgl
    REF 3d7daa62b37e7b3504a372f2c93236052952d0f8
    SHA512 48014a5e5bec23ebda34d97f1c3aeb511271e17dac203258668a94a8004c01b7460ddfd7086b6db911d4e8800b61cf2bdc5a11b597cc22317cfef45364cf20fd
)

file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${SOURCE_PATH}/BuildTools\"")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
