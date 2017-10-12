include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nholthaus/units
    REF v2.3.0
    SHA512 1b9d7806e82d0f437574562e647077b6d22c0add81a19b5ec71f53ab608642db2d785a70d03d13cb2eeea2a8bc2d20f112b6bdf49acf0afce44e8e07bb6b7c39
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/units RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/units)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/unitsConfig.cmake ${CURRENT_PACKAGES_DIR}/share/units/unitsConfig.cmake)

# remove uneeded directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)