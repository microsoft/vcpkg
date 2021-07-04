#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/comms_champion
    REF v3.3
    SHA512 c60dc6c1ab67a2a5e26468255151ff9f5cbf4a2d7824c8f2ed0f8648b51170150fba26ab6072de9733b8b6e60272f28610d41d6b9df7994a0406f78aed5c686e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCC_COMMS_LIB_ONLY=ON
        -DCC_NO_UNIT_TESTS=ON
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/LibComms/cmake TARGET_PATH share/LibComms)
# currently this is only a header only library. after moving lib/LibComms to share this lib path will be empty
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
