vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO carnegierobotics/LibMultiSense
    REF ${VERSION}
    SHA512 4fb2343fc2288792c732e7e61cb447b953ed8e8354c3c1e401c5b2bc8151f4b3d8f692882e015e5e56d8dc2d08f121a798138a6974d3b02348b1689c9015fe00
    HEAD_REF master
    PATCHES
        fix-missing-algorithm.patch
        fix-find-package-config-file.patch
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
            ChangeIpUtility
            ImageCalUtility
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
