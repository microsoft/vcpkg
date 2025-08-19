vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO carnegierobotics/LibMultiSense
    REF ${VERSION}
    SHA512 69472f288de46c0ecdbbbcb8c280610c1c80778d660098e3b639ab653b108096c3fb4cd92a21afd4745b959a0c80812c5bf2d42053760bbceeafd90e67c20388
    HEAD_REF master
    PATCHES
        json-serialization-dependencies.patch
)

vcpkg_check_features(
        OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES
            json-serialization BUILD_JSON_SERIALIZATION
            opencv BUILD_OPENCV
            utilities MULTISENSE_BUILD_UTILITIES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_LEGACY_API=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "MultiSenseWire"
    CONFIG_PATH "lib/cmake/MultiSenseWire"
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "MultiSense"
    CONFIG_PATH "lib/cmake/MultiSense"
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if ("utilities" IN_LIST FEATURES)
    set(_tool_names
        ChangeIpUtility
        ImageCalUtility
        PointCloudUtility
        RectifiedFocalLengthUtility
        SaveImageUtility
        VersionInfoUtility
    )
    if ("json-serialization" IN_LIST FEATURES)
        list(APPEND _tool_names DeviceInfoUtility)
    endif ()

    vcpkg_copy_tools(
        TOOL_NAMES ${_tool_names}
        AUTO_CLEAN
    )
endif ()

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE.TXT"
)
file(
    INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
