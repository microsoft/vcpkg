vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/sratom
    REF "v${VERSION}"
    SHA512 81d58155f3d42f1a3671632ef0ab1e5dbbf756e23378b03034b626dcf1d23b00b9763d153e3dbd1183571f089dfa1f2501cc68b5ce7a1ca337979bc148bb9210
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
