vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/upb
    REF  160625a9728b4031a21ad1e1c0146ea2c3a851eb # 2021-10-19
    SHA512 13b205dd4278600e6ec05c829dc6c7e449747cccb118a3b83abc0ab5ef0ab180feb364ac84da8075471697fbba798ed3d9d763934d7fe9a64ac0560f5f9d3e83
    HEAD_REF master
    PATCHES
        fix-uwp.patch
        fix-cmakelists.patch
        add-all-libs-target.patch
        add-cmake-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
