vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDUtils
    REF 0ee5bf54fe82c4ef59f1ee586bf7e2b343758f62
    SHA512 0410017b79f2d650457f5b2406b5ca3c5163b57ed4ce67d94c9761c865e1662e23d4148c8a77233adf8ecd2d77906cf9e231d802834425a7f1c1903871e30516
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        testing    KDUTILS_BUILD_TESTS
        mqtt       KDUTILS_BUILD_MQTT_SUPPORT
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
                      OPTIONS
                      -DKDUTILS_BUILD_EXAMPLES=OFF
                      ${FEATURE_OPTIONS})
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Fix CMake config files - each module goes to its own subdirectory in share/
vcpkg_cmake_config_fixup(PACKAGE_NAME KDUtils CONFIG_PATH lib/cmake/KDUtils DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME KDGui CONFIG_PATH lib/cmake/KDGui DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME KDFoundation CONFIG_PATH lib/cmake/KDFoundation)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
