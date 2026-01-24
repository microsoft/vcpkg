vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spnda/fastgltf
    REF "v${VERSION}"
    SHA512 b18162eb8a1631d9a28ed97961ac8f08d6aa2797f2bf035a470660cfd052f25c2bd47b77ce2c3f5367d5006c706cf6e00a710c14a25ad5e02b619430ea076882
    HEAD_REF main
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
