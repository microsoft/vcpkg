vcpkg_download_distfile(PATCH_FIX_ANDROID_ISSUE_74
    URLS https://github.com/spnda/fastgltf/commit/e42df8b70d42f62fa9c678c23213e9cb649b9060.patch?full_index=1
    SHA512 1f205aef9fa5658f7139304002528db612e5f6d74b8281a568c52a0bcd94830c113c9875ea887374785ad041139ee336a66de1881179b0317900249a1140f537
    FILENAME spnda-fastgltf-v0.8.0-e42df8b70d42f62fa9c678c23213e9cb649b9060.patch
)

vcpkg_download_distfile(PATCH_UWP_DISABLE_MEMORYMAPPEDFILE
    URLS https://github.com/spnda/fastgltf/commit/279d960eee4c85690c90df92ce0bdc121a6233f4.patch?full_index=1
    SHA512 4f837e03c9b3ee3333a09b675e2395b300fff8e8231962a26da18e32d84cc9099bf231c174ca100c324e45beb0891fb5aeea40f35d71881350d845e6e2c95cd6
    FILENAME spnda-fastgltf-v0.8.0-279d960eee4c85690c90df92ce0bdc121a6233f4.patch
)

vcpkg_download_distfile(PATCH_UWP_WINAPI_FAMILY
    URLS https://github.com/spnda/fastgltf/commit/5278229d48e06d4770ecfea97402bbe1c8380038.patch?full_index=1
    SHA512 2521859f6126d0602ac9d641553ab502ad21ccc6f9227cf23da16ae7ae6df77f53b9a2b883c52a9ae191476a57a07e0008aa42f00c61cef09cc5d7145586e729
    FILENAME spnda-fastgltf-v0.8.0-5278229d48e06d4770ecfea97402bbe1c8380038.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spnda/fastgltf
    REF "v${VERSION}"
    SHA512 7fbc479e03b26ef246625abd86b005ed1dde84e607346e890b71abffc2b26cf7b59880ab286526da5b811dd1f74cff9a6d44d65e128154fcd0f1c540dc11f1f5
    HEAD_REF main
    PATCHES
        "${PATCH_FIX_ANDROID_ISSUE_74}"
        "${PATCH_UWP_DISABLE_MEMORYMAPPEDFILE}"
        "${PATCH_UWP_WINAPI_FAMILY}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
vcpkg_copy_pdbs()

file(READ "${CURRENT_PACKAGES_DIR}/share/fastgltf/fastgltfConfig.cmake" contents)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/fastgltf/fastgltfConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(simdjson)
${contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
