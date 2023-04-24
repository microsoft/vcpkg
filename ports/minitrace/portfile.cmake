vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hrydgard/minitrace
    REF a45ca4f58c8af2fc4d4d6042e68aa68bfea422c9
    SHA512 5ea6fb58a1f2397444e58e449fd32b4b45f5a15afe8f8694115a0025f5444cf493ba8228a58f0772ca1dc149fd1633fc897b0a264b8927cfd6cc15eefa40c336
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/minitrace" RENAME copyright)
