vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BehaviorTree/BehaviorTree.CPP
    REF 40b5cc9cd9a9b46746ddb27aa325f9b13aa749de
    SHA512 102861bb615f5e42897457c8a688c3652de2823d216633448dba836c4f26b72643aabc9906482857f56ed70c009f7c020c1a4e8dd8c61481c3fc3cd39f23c198
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "coroutines"  ENABLE_COROUTINES
        "tools"       BUILD_TOOLS
        "examples"    BUILD_EXAMPLES
    INVERTED_FEATURES
        "recorder"    CMAKE_DISABLE_FIND_PACKAGE_ZMQ
        "curses"      CMAKE_DISABLE_FIND_PACKAGE_Curses
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_UNIT_TESTS=OFF
)


vcpkg_cmake_install()
vcpkg_copy_pdbs()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES bt3_log_cat bt3_plugin_manifest AUTO_CLEAN)
endif()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/BehaviorTreeV3/cmake
    PACKAGE_NAME BehaviorTreeV3
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/lib/BehaviorTreeV3"
    "${CURRENT_PACKAGES_DIR}/debug/lib/BehaviorTreeV3"
)
