vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pellegre/libcrafter
    REF 86f81f101b5e3051ed04563b3ad3dd7a823afb21 #version-1.0
    SHA512 bd0eac06896df63f0fff0ed3cf7ca5176e56615476c8134bd26f035692ab9e583f58f1f57daa7673771a710d6921c0c6a6473ab181982ad57727584f2cde56d0
    HEAD_REF master
    PATCHES fix-build-error.patch
)

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH libcrafter
    OPTIONS
        "--with-libpcap=${CURRENT_INSTALLED_DIR}"
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/libcrafter/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
