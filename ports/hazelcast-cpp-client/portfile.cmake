vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hazelcast/hazelcast-cpp-client
    REF "9cff5efc6adaa927555c69c2e3aa3f5bb804d8f2"
    SHA512 bb90792e441f79f7fa5d45830d32f8b521ae45843ba5a3115af0bda70ccb2a7afa270a43a23b30770c8e7ed1101d4bb06d1619e16b852474c59bfaa44c27681a
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
