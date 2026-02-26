vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sogou/workflow
    REF "v${VERSION}"
    SHA512 ed38ce31c39d5f51497379f4184c7890d30b1e683973cd363f7921e628cf1d731bbbbe77f8cece1195cea2199e64d503ea4ed2bfb350d09fc22c862abd497577
    HEAD_REF master
    PATCHES
        cmake.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # because configure_package_config_file to ${PROJECT_SOURCE_DIR}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/workflow")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
