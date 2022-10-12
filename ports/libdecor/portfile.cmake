vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jadahl/libdecor
    REF 0.1.0
    SHA512 7e228b276efc98894085398ac8b4a37fb23a8ce3dfbb16c3d664d833f99e7d6365c43276880ef36d21d6471e1cdcae1925e6daaf95b4904b5701d103e023a916
    HEAD_REF master # branch name
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Ddemo=false
)
vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
