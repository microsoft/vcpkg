vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/mm-common
    REF 1.0.4
    SHA512 58a6202115a7c888306d169a0850c5cdbe44c9bbf1e29a4569051a9feeea47bce830615640d2b83ba4396a9d930d65834964e91c534ffe9922eecfcfbf1259c9
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
