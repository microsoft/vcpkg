include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cpp-niel/mfl
    REF v0.0.1
    SHA512 eb6dd706b6bdfe4cb8a57392602f1c00cceed85d1dd43703532e497a8140711ead4e3d28670aeec960fb63085397264ccce356a95a9b501e5bffe9f7a931aa52
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/mfl TARGET_PATH share/mfl)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mfl RENAME copyright)
