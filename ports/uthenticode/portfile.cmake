vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO trailofbits/uthenticode
    REF v1.0.2
    SHA512 0e92be1a1b918c03074a4c083c4bffeb318f348c76ba34c3244c2594f244f887819040e91b2e7d8bb5ac573007c7b3a2a72d4f71abeee0e252d7bfe60c68cb11
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/uthenticode TARGET_PATH share/uthenticode)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(
    INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)
