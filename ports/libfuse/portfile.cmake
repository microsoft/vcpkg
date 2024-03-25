vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libfuse/libfuse
    REF "fuse-${VERSION}"
    SHA512 e82581eec24f464bab7a2e2c18fa6b738e6f9f3f0a065c74a18727549159595d69e98772af87fa31fe1e632a6808cc40a788ad3d0330aba4937d4326b8bd5862
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