vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-DDS
    REF b1779b608c7b5b2dcb101728f4213c58bdde74ee # waiting for next release
    SHA512 f316a71784cdac5379b1cf59cee4bf57304aa59a73563fcbdd141b0d1297302048ca73817adca68baf18472e74f200af9490d2d6fa6124863ec260546fb373e4
    HEAD_REF master
    PATCHES 
        fix-install.patch 
        namespace_tinyxml2.patch 
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/fastrtps/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/examples)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/examples)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/fastrtps)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/fastrtps)

file(RENAME ${CURRENT_PACKAGES_DIR}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
