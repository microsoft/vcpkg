include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/breakpad
    REF 88e9a460dec52d11ce4520c54246cf5cf29f87bf
    SHA512 31750e6db23c30b884af7049dc67cd30198e49a638d3e226c5ba31f562145bdfbc42f0679173cefc93df75b11af734ecf164c0d4030408e6f0ab315d60fdb30f
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-breakpad TARGET_PATH share/unofficial-breakpad)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/breakpad RENAME copyright)
