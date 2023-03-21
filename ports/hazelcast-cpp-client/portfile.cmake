vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hazelcast/hazelcast-cpp-client
    REF "v${VERSION}"
    SHA512 1e4203b546f3737e7fd2ea7a7ed04fa5b0663e7c319ed796140407d4e56d70e40eb5a9497d9f9eb7be182b038efe36f6ba1a42f10d24d3732cf54886c40db8eb 
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
