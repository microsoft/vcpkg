#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/gli
    REF dd17acf9cc7fc6e6abe9f9ec69949eeeee1ccd82
    SHA512 9e3a4ab9ee73d5c271b8346cf81339cd3cd0c20d20991524b816313b6a99e8d3a01863316a38cf1a52ef9c5b31d689ecccf6248b12d1d270460c048bf904650b
    HEAD_REF master
    PATCHES
        disable-test.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/gli TARGET_PATH share/gli)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/gli/CMakeLists.txt)

# Put the license file where vcpkg expects it
# manual.md contains the "licenses" section for the project
file(INSTALL ${SOURCE_PATH}/manual.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)