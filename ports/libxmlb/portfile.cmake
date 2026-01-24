
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hughsie/libxmlb
    REF "${VERSION}"
    SHA512 534e5fe01727b9427137c51984c9ddced91b842c712d4f34f582193c838429b396be6e444246b324d39f6732fdf582a7d89570049f4f48d4a161aff82e33aa49
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
