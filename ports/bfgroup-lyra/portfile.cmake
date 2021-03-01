vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bfgroup/Lyra
    REF 1.5
    SHA512 1f8e505a487a9421a59afed0ee0c68894fb479117ac20c0bbb8d77ccf50ab938a68c93068f26871b9ddff0a21732d8bb1c6cc997b295a2a39c9363d32e320b3b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(
    CONFIG_PATH share/lyra/cmake
    TARGET_PATH share/lyra
)

# Library is header-only, so no debug content.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
