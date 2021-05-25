#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/comms_champion
    REF v3.2
    SHA512 4ca0c1e074715126edae0bd8fda62bb2cbe2151887f755a1874e21d15e050e0c7248bb50ba2e9a5da52611f48fab8e3dd7d5cc402cad134684c1ebb85aa5348a
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
