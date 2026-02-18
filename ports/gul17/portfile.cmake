vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gul-cpp/gul17
    REF "v${VERSION}"
    SHA512 4529b4d3bc3dcb2c1553b54f93c71ce7640b28aa823d0cece07b2739962fe05fe2df3dc06165ea754e59de7af065813260180cf779e8716598d595385d5c9914
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Dtests=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Install copyright file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
