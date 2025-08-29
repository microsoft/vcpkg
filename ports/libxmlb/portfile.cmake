
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hughsie/libxmlb
    REF "${VERSION}"
    SHA512 ab80012fc8c0c9b70c8d77f931cd3ff0f0f62086d9b26c490b1b942f7be8dc72d9797d5995c7edcfc36652e3562650e47b2cead87103e06077c7b7e19ec8230f
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
