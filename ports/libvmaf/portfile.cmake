vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Netflix/vmaf
    REF "v${VERSION}"
    SHA512 46400c017235caf38c86e428da76990a7e828dcf7df19a1ac71323906a78760f2cb37853ba4578352fced942c967a1661ff28bbf72e2ef566bf4b7ccd48135a8
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
