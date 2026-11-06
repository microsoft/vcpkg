vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDUtils
    REF f3ab82a6caedd2f80387276aee0e286fb54fdfcf
    SHA512 09712e6ed506d42774448aece2d34c45d6cccf2f9e6a5c8a9b7ada19b4aee79ae6ccbb460b303bfe07d590affc6d8757a5761e2b573d8a10865ffa99a1afdf4d
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
