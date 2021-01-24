vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/hidapi
    REF 00fe9c0b259078fcfb6fbabbc3e619cb7f45a726
    SHA512 6ce7c777afd73964f4cefd0c3a39dfca745d399205bcdc82889aec4bb13bdb6fd2c06f9ab955be566fe958e08a5b41f6cb39417c701d8a1d38abd427b2668fa1
    HEAD_REF master
)

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH} OPTIONS -DHIDAPI_BUILD_HIDTEST=OFF)
vcpkg_build_cmake()
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/LICENSE.txt
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
  RENAME copyright
)
