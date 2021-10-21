#header-only library

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
        tools   CC_BUILD_TOOLS_LIBRARY
        tools   CC_INSTALL_TOOLS_LIBRARY
        tools   CC_BUILD_TOOLS
        tools   CC_INSTALL_TOOLS
)

# check before configure
if("tools" IN_LIST FEATURES)
    vcpkg_fail_port_install(ON_LIBRARY_LINKAGE "static" MESSAGE "Feature 'Tools' can't be built statically") 
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCC_INSTALL_COMMS_LIB=ON
        -DCC_BUILD_UNIT_TESTS=OFF
        -DCC_WARN_AS_ERR=OFF
        -DCC_BUILD_DEMO_PROTOCOL=OFF
        -DCC_INSTALL_DEMO_PROTOCOL=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME "LibComms" CONFIG_PATH "lib/LibComms/cmake" )

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES cc_dump cc_view
        AUTO_CLEAN
    )
    file(INSTALL "${CURRENT_PACKAGES_DIR}/lib/CommsChampion/plugin" 
         DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/lib/CommsChampion/plugin")
    vcpkg_cmake_config_fixup(PACKAGE_NAME "CommsChampion" CONFIG_PATH "lib/CommsChampion/cmake")

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/LibComms")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/CommsChampion")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/LibComms")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/CommsChampion")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
