vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Netflix/vmaf
    REF "v${VERSION}"
    SHA512 392b7289bc18653548c62e763ab8398084a6d32f73c3662495e2b39b02d5b4aa5d4ebaebba329cbb331691b0564f9d0298cdb011b3fe5dfdaf2b89ed50c59d70
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
