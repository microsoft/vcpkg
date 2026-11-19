vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slirp/libslirp
    REF "v${VERSION}"
    SHA512 e7ab5bae9696a5b3f9bc0a846757a5d7a9dd24407c04f1c3483730baa0b0269fb9574c5f26569f1718a4b51023a62a5c4b8826a82e5c44b8d14a1ede5fb7e566
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
