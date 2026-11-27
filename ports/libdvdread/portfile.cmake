vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://code.videolan.org/
    REPO videolan/libdvdread
    REF "${VERSION}"
    SHA512 0f2808619d307147b58e74989d81966bf8bb93cd05e24b34e3ab782c1ae907b7020837c5f8dca365c3688f3eae436a6fa196382b1a060af94de9475b9b6ade50
    HEAD_REF master
    PATCHES
        file-win32-no-unistd.diff # https://code.videolan.org/videolan/libdvdread/-/commit/cdf2a8e1284a9532a7d6ee94eb4767cefc899e79
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Denable_docs=false
        -Dlibdvdcss=enabled
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
