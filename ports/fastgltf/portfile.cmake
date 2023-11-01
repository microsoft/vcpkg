vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spnda/fastgltf
    REF "v${VERSION}"
    SHA512 2dbc93eb6ddb84860b84004e4bfecc0d41a514c719534ce48c3be97dce0ec8b171005c1689f3c97631bf3cb7620f937b60ce27222b99593ef3a0faaf8974a952
    HEAD_REF main
    PATCHES find_package.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DFASTGLTF_DOWNLOAD_SIMDJSON=OFF
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
