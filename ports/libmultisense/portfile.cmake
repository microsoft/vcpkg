if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO carnegierobotics/LibMultiSense
    REF ${VERSION}
    SHA512 354c9eec33e9153496b0858b8dc6e5735218585abecf885f356f643d833ebf00a63fc4571634283c430de07045f2be544b0e6d445599fce4c1655af671b758bd
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
            DeviceInfoUtility
            ExternalCalUtility
            FlashUtility
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
