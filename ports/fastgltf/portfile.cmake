vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spnda/fastgltf
    REF "v${VERSION}"
    SHA512 6cda7e50d7fe01428e0a03d3f590fe7b680bfa4b6fcdbd1c6a118ac01c925099e63b34380b053adc323e2aaaaead42bda450d1eaf66b60af6ad2aafb68828d01
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
