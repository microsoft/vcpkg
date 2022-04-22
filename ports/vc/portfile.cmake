vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  VcDevel/Vc
    REF 1.4.2
    SHA512 9a929cd48bdf6b8e94765bd649e7ec42b10dea28e36eff288223d72cffa5f4fc8693e942aa3f780b42d8a0c1824fcabff22ec0622aa8ea5232c9123858b8bbbf
    HEAD_REF 1.4
    PATCHES
        "correct_cmake_config_path.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Vc/)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
