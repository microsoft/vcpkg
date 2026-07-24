vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libfuse/libfuse
    REF "fuse-${VERSION}"
    SHA512 b870e13d97d62546aab2e29855c775a7492b2b4ad0115bfd0ab68aa5505d6baa071e29e93ed67f7cff16ab71704bb8f9ffe8253c3edc0f9fd396186b1deef6fb
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dutils=false
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
