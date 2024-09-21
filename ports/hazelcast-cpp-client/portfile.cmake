vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hazelcast/hazelcast-cpp-client
    REF "v${VERSION}"
    SHA512 9f6668fe88b1e10e1c91fea26acb12efab464f652d9008e43b06d92413a7bc4b66cd0ef00c0643ddf12c8d29b099cd767209a096e609fa214233dcc3288d194e
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
