
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hughsie/libxmlb
    REF "${VERSION}"
    SHA512 79912466efa7c0a6db71a4fb66502a1665191d852a900dd666c9c5b780c9befb6270ebb1f3b7e1265115ac930a0bdbc0ba00bd8bbd25aaa843bd22aabbe7be19
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
