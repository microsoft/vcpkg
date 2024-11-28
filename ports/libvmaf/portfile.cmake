vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Netflix/vmaf
    REF "v${VERSION}"
    SHA512 9e356bb274ce7d5d85a64d2a1a122ea9d267809edd83bb6e663fb348a1a46355882eb9044982bf679f03df7f93c6f66c9b0d9a94661979b2c722db30b21c4f32
    HEAD_REF master
    PATCHES
        no-tools.patch
        android-off_t.patch
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_PATH "${NASM}" DIRECTORY)
vcpkg_add_to_path("${NASM_PATH}")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}/libvmaf"
    OPTIONS
        -Denable_tests=false
        -Denable_docs=false
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
