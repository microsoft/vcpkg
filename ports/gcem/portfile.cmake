include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kthohr/gcem
    REF v1.12.0
    SHA512 cb28dce44e8aac2a4369bc1dd796243f0f9ff25bdd2effcff198b6e4ad1161ed4d33d2fdc7aca0ca9b538c769c1ae36ebfd7fcfbefd289bb1a62cdbea1957f74
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
