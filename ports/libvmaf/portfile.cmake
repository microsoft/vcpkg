vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Netflix/vmaf
    REF "v${VERSION}"
    SHA512 5bd78c6370642612d52f5370f10cd38edb335be57a2252be4f4242b00653c4e0f2c93ab611581e8fed30c52107963fb410a00408033f26e22b5911eed1d0bfde
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
