#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/comms_champion
    REF v3.1.4
    SHA512 4902f8f165200116fe49bc313fc0808bac820f4e5e9084f9bf4e6c1d74ab71a3a056f4b3614b617e71f62cb37346956c69d83b77eb92dd7d9ad0918f1b5edb33
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
