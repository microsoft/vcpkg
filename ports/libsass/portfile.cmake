vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sass/libsass
    REF 8d312a1c91bb7dd22883ebdfc829003f75a82396 # 3.6.4
    SHA512  41e532c081804c889c3e7f9169bd90d7fc944d13817d5e3a4f8c19608ebb630db2b2b0e9c61a59a2446076f4093d5ec4cb4f767aa06fa0bf0f0687094e1a2913
    HEAD_REF master
    PATCHES remove_compiler_flags.patch
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    OPTIONS

)
vcpkg_install_make(MAKEFILE GNUmakefile)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()


# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
