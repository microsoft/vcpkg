vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sogou/workflow
    REF "v${VERSION}"
    SHA512 a2befaa1042ff6a37f03869972ac7408dc8527a8f381a5fd3262e06ff3d766b14d9ecccab822278fd69f8236e8d74b68248f985ab2a85da941b28e8bbbd6dffd
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
