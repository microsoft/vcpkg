vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/comms_champion
    REF v3.4
    SHA512 573afbc0aebd72d8a047067410f0f54588675c4cbad37f824edbb6d8303e9c191c573ac9325bf5fec575dffd3d05562c04e75c1e5b748a34d01056bc8b766fb1
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools   COMMS_BUILD_TOOLS
)

if(COMMS_BUILD_TOOLS)
    set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DCC_INSTALL_COMMS_LIB=ON
        -DCC_BUILD_UNIT_TESTS=OFF
        -DCC_WARN_AS_ERR=OFF
        -DCC_BUILD_TOOLS_LIBRARY=${COMMS_BUILD_TOOLS}
        -DCC_INSTALL_TOOLS_LIBRARY=${COMMS_BUILD_TOOLS}
        -DCC_BUILD_TOOLS=${COMMS_BUILD_TOOLS}
        -DCC_INSTALL_TOOLS=${COMMS_BUILD_TOOLS}
        -DCC_BUILD_DEMO_PROTOCOL=OFF
        -DCC_INSTALL_DEMO_PROTOCOL=OFF
)
vcpkg_install_cmake()

if(COMMS_BUILD_TOOLS)
    vcpkg_copy_tools(
        TOOL_NAMES cc_dump cc_view
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/bin"
        AUTO_CLEAN
    )
    file(COPY "${CURRENT_PACKAGES_DIR}/lib/CommsChampion/plugin" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/lib/CommsChampion/")
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/LibComms/cmake" TARGET_PATH "share/LibComms")


# after moving lib/LibComms to share this lib path will be empty
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/CommsChampion/plugin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/LibComms")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/CommsChampion/plugin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/LibComms")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
