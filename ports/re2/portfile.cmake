vcpkg_download_distfile(PATCH_488
    URLS https://github.com/google/re2/commit/9ebe4a22cad8a025b68a9594bdff3c047a111333.patch?full_index=1
    SHA512 167a0153bf24e77db2b8555a7d6391acf740dc4720a71e6ce19a3533c7e0a49923d9584ff32544a454837a25eedace00cb2ef9ddbf4250deb5f2c5aeda04ac26
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
