vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/sratom
    REF "v${VERSION}"
    SHA512 e21cae1cec929b88f81c50845ed8feeb8659ec9afd240224023dc6ab3906ec634afc4e5c2e84b66cdd0792303d5b53232b9c590cbbe08cb968f3e17dab7c8ac7
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
