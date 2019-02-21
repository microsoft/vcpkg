include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kthohr/gcem
    REF v1.8.1
    SHA512 dd82a917822ffdfb3f224599340d2a0499e47db8d469d9febf3d37cd796fae3c8186a4fc05cc727d3ef82655359166caafbb5ddee3b79ba7becf1a53cce20e4a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/gcem)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gcem)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gcem/LICENSE ${CURRENT_PACKAGES_DIR}/share/gcem/copyright)
