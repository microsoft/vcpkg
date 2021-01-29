vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO daniele77/cli
    REF v1.2.1
    SHA512 fc834608ac2ca6c3f330711c80897cc581eb1ed8da7a0d56a07efe6650d871f5317c777a6a029fdc0177684f08479bd129cc0ce748354bac3dbe6af79a390d14 
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cli)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
