set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_check_features(OUT_FEATURE_OPTIONS feature_options
    FEATURES
        full-runtime PROTOBUF_TEST_FULL
        libprotoc PROTOBUF_TEST_LIBPROTOC
        zlib PROTOBUF_TEST_ZLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        ${feature_options}
)
vcpkg_cmake_build()
