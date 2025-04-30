if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO carnegierobotics/LibMultiSense
    REF ${VERSION}
    SHA512 bb9ccba46e02f0f56e93a54ce0b07ec18873c018667701043db8eab4e123fd3e48f06586f11a2f2edc2c5becb0e906cb9555dedd781f750c6333b674b42d550e
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        utilities MULTISENSE_BUILD_UTILITIES
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

set(PACKAGE_NAME MultiSense)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "${PACKAGE_NAME}"
    CONFIG_PATH "lib/cmake/${PACKAGE_NAME}"
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if ("utilities" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            AprilTagTestUtility
            ChangeFps
            ChangeIpUtility
            ChangeResolution
            ChangeTransmitDelay
            ColorImageUtility
            DepthImageUtility
            DeviceInfoUtility
            ExternalCalUtility
            FeatureDetectorUtility
            FirmwareUpdateUtility
            ImageCalUtility
            ImuConfigUtility
            ImuTestUtility
            LidarCalUtility
            PointCloudUtility
            RectifiedFocalLengthUtility
            SaveImageUtility
            VersionInfoUtility
        AUTO_CLEAN
    )
endif ()

file(
    INSTALL "${SOURCE_PATH}/LICENSE.TXT"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"     
    RENAME copyright
)
file(
    INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
