vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slirp/libslirp
    REF v4.7.0
    SHA512 387f4a6dad240ce633df2640bb49c6cb0041c8b3afc8d0ef38186d385f00dd9e4ef4443e93e1b71dbf05e22892b6f2771a87a202e815d8ec899ab5c147a1f09f
    HEAD_REF master
)

if(VCPKG_HOST_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
)

vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libslirp" RENAME copyright)
