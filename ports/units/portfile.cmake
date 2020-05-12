vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nholthaus/units
    REF v2.3.1
    SHA512 1ec9e4d7d60f073ad82a02116f16b9dda57406a3b22a5b06d34f9e5a4df8fd20cc28fc7acfd8fc33054718e0efca3973df0424563f7e1833687a6c1696b9c340
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# remove uneeded directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)