vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF c34f83a68e60537eba52e2d076ed22495ad4c5df # v.0.6.8
    SHA512 1c03a2cc96f44ce004870136ffdaa7a9abc5bc5173edadfe58e4f92f2e3c67c1555b4604094ad3a1dab1f0bf01cf9d79cf7d5a381f357aa4bdff90656a27e0c1
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/vcpkg
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
