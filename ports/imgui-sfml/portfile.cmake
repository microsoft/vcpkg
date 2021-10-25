vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eliasdaler/imgui-sfml
    REF 82dc2033e51b8323857c3ae1cf1f458b3a933c35 #v2.3
    SHA512 f27a0e65aa20229c73b27c4232269908dfeb5d78b1cef7299a179ecac6194d9829e148e95ed54b4500ffd36ada09fdbfadf67588c78bee87aff446ae80347bcf
    HEAD_REF master
    PATCHES
        0001-fix_find_package.patch
        0002-fix_imgui_config.patch
        004-fix-find-sfml.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME ImGui-SFML CONFIG_PATH lib/cmake/ImGui-SFML)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
