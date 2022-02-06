vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slirp/libslirp
    REF v4.6.1
    SHA512 04a9dd88cd58c849a24b9cff405d951952760d99ea2bef0b070463dff088d79f44557a13c9427ba0043f58d4b9e06b68ff64a4f23a7b0d66df594e32e1521cae
    HEAD_REF master
)

vcpkg_acquire_msys(MSYS_ROOT)
vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
)

vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libslirp" RENAME copyright)
