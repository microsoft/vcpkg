
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hughsie/libxmlb
    REF "${VERSION}"
    SHA512 7e437ae7a7104eb2f8de36ea319fd79c130edd794d96243dbca50f839494e0aa5377954cd38618e310cea8b6a246b2049150b37f3d4da8dea56149baeb543e45
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
