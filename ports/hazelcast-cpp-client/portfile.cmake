vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hazelcast/hazelcast-cpp-client
    REF v5.0.0
    SHA512 7cf85eadeed212871d2a6c5c0aa9d9640c9c89e126c3e383981ddd4cb222390e4ce8307b554766666b8d7816bd5e0fed4242bc674e20423570726c261c182559
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
