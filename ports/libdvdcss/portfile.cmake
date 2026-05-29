vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://code.videolan.org/
    REPO videolan/libdvdcss
    REF "${VERSION}"
    SHA512 276ab26a7295bb45dd852c8d8ad262dfb6f8bc4dae347b1f83ac6949aaea4cabf4cf84f79dabf2442d207c1f9bffca07793748794aa338a4694327672326799b
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
