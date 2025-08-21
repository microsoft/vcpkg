vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://code.videolan.org/
    REPO videolan/libudfread
    REF ${VERSION}
    SHA512 3069feb5db40288beb5b112b285186162a704f0fdd3cf67a17fd4eeea015f2cfcfbb455b7aa7c3d79d00fd095a3fd11cffc7b121dce94d99c3b06a509a8977d2
    PATCHES
        msvc.diff

)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
