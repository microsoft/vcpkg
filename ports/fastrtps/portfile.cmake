vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-DDS
    REF 40568fa4784e846f95c461608d43a2b57eaef55b # v2.0.1
    SHA512 a0cb48713a41ba3562c98dfc176508779e70e35b573428ac0a74c74254aa34c583bd545169f3a3961172bfc9e7bb14d08b5d56569e176fe8248d714bec5813a4
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/fastrtps/cmake TARGET_PATH share/fastrtps)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
