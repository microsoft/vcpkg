vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eliasdaler/imgui-sfml
    REF 9cc8c57a4565551087be0d9aeb3ae55490aa1207 #v2.4
    SHA512 d44d85e44d17d05c4e21f71acbf5bf544364a9bbe4871be896edd29f9926948cd1ea7627b7d54524f7da64c494638fc126744ced57ea7997a4b712dd26eb6183
    HEAD_REF master
    PATCHES
        0001-fix_find_package.patch
        004-fix-find-sfml.patch
        005-fix-imtextureid-define.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME ImGui-SFML CONFIG_PATH lib/cmake/ImGui-SFML)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
