
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hughsie/libxmlb
    REF "${VERSION}"
    SHA512 88f884c47d091335d5867936eca1160e6553950ce4bf54052bccb2a4a95725d446d23a13d747b3a919506342de16c0d90d6dfe313eb3cd49886488fad8e938a5
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dgtkdoc=false
        -Dintrospection=false
        -Dtests=false
        -Dstemmer=false
        -Dcli=false
        -Dlzma=disabled
        -Dzstd=disabled
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
