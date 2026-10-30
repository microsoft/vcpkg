vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brazier-tech/brazier
    REF de7737277a28499b6eb911227ad1996c35d318bc
    SHA512 895ba754e2ab740d6e38b3ccd710eec3873c8c4c86154dd01d92fc996a6046579ff6d6f2e528b170cff841eae8e64b9bd6670d8f9a32c95ef12c1c5a2c2e89f2
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/brazier" 
    OPTIONS 
    -DBUILD_TESTS=OFF
    -DBUILD_APP=OFF 
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME brazier-core CONFIG_PATH share/brazier-core)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/COPYING")
