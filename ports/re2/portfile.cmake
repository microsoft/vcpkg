vcpkg_download_distfile(PATCH_488
    URLS https://github.com/google/re2/commit/9ebe4a22cad8a025b68a9594bdff3c047a111333.patch?full_index=1
    SHA512 83c1a4cc4ddd6e1443f5201f7f00cf6a0729d0a0fb8fc5068c3d80766238d72f019f1fddaeffebcc2d4322a07daf2203214121cdda039b10a5f39214b9fa8647
    FILENAME 9ebe4a22cad8a025b68a9594bdff3c047a111333.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF "${VERSION}"
    SHA512 1511d163ee90c724705cc16d2995e777a7d894ff8133bd3457a26d8c6a9dcb8ccdd2e77b73681e623317a1edbbd3c928569358af91e72ce8612f7b7b61108283
    HEAD_REF master
    PATCHES
        "${PATCH_488}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRE2_BUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
