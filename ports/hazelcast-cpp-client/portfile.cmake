vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hazelcast/hazelcast-cpp-client
    REF v5.1.0
    SHA512 ffb7a00f432098b64e1455074843ca7d592b4ccf169f6c51234840ca13dc9f69ef424b1ace04455a80a6f93d230d44d5323baa4b95017f84c71f1e31ff320088 
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl WITH_OPENSSL
        example BUILD_EXAMPLES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/hazelcast-cpp-client)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
