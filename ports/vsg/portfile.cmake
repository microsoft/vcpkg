vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/VulkanSceneGraph
    REF "v${VERSION}"
    SHA512 a9a1d2f82badc393b7be8db9616ef6bd5fa74cd65f83dd65d7d7344b61eb9d52d24f34de71f98f2de1a5bd4c41c7aae5e538a4f58346ff1a9ec5108cbef759cf
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "vsg" CONFIG_PATH "lib/cmake/vsg")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
