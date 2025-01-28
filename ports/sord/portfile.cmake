vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drobilla/sord
    REF "v${VERSION}"
    SHA512 73011eba2beea1620f6ca2a911ac331e7a5b31835361893158ac04345504d7d071525fcae6126c2bd87e087c0a407afbd7dbcd37020a3e43cdf5679cb4b27a8b
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_tools(TOOL_NAMES sordi sord_validate AUTO_CLEAN)
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
