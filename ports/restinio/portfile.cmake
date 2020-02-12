vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF 1b6fdc114991ccc726b1b90153eee535106a6367 # v.0.6.4
    SHA512 68a735502f8f10e20e6caa5ed918166dc8448e5a0dfa3c6ee0cf3d43768ef7a27ffbfbe46c440dce9b846e5e6762818a9614c2d48aa67dbc03adb1854b28928b
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
