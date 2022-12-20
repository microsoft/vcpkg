vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nothings/stb
    REF 8b5f1f37b5b75829fc72d38e7b5d4bcbf8a26d55
    SHA512 76e0ed7536146aac71f89d6246235221c1dc0bd035ae4b33d496213acf5be95413cae4455a3f1419f84113320f7bd662dc50b47788cbdc8e7208bbbbcfd23f98
    HEAD_REF master
    PATCHES
        organize.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
