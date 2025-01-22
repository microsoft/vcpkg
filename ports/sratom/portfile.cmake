vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/sratom
    REF "v${VERSION}"
    SHA512 938326f598ccf0010bfd7517c4a98f3729f9db1d771c990fcc6b8e008b44970c34b65aa6d491b99250067428501218b11f185a7282484a7b62217b7f2961c40d
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
