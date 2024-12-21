vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nibanks/msh3
    REF v${VERSION}
    SHA512 dedd8be43e44b4bebbf601d76b1f3b0135501330ed128ca710de942ef7d9142a21f1c1eb9efecf57881e72d93d68c7c2c085bc35d402eac5eabc57e77773be6b
    HEAD_REF main
    PATCHES
        dependencies_fix.patch
        width-exceeds-type.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
