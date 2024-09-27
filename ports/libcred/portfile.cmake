vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mamba-org/libcred
    REF ${VERSION}
    SHA512 2b86cf0017c8e43f6d6eba378c00b56781b5d70b73d6251d8acde49f7fc698b41aaf2f0bb293211836ec9c3779828ae95cdc4041f3d0147c37352df007ad82bf
    HEAD_REF main
)

set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

vcpkg_configure_meson(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_install_meson()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()