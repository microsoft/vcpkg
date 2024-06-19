vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/LightGBM
    REF v${VERSION}
    SHA512 295ea23ec55164232f1dde6aa46bcfa616e2fe4852eb2e3492e681477a8d7757875d60379c4d463a35a6a9db56b1f4bce86b3a03bed56ea3d36aadb94a3b38eb
    PATCHES
        vcpkg_lightgbm_use_vcpkg_libs.patch
)

# Fast double parser is a non-vcpkg dependency of LightGBM
vcpkg_from_github(
    OUT_SOURCE_PATH FAST_DOUBLE_PARSER_SOURCE_PATH
    REPO lemire/fast_double_parser
    REF efec03532ef65984786e5e32dbc81f6e6a55a115
    SHA512 2917167f05a270253b4c6360b598a69df43e8305601abb59d12c4085dd5db0b93b0e8725f61595a0424f0a26b59ec1a97d58df1ab33674ce36f0da9bd818c485
    HEAD_REF master
)

# Remove exisiting folder in case it was not cleaned
file(REMOVE_RECURSE ${SOURCE_PATH}/external_libs/fast_double_parser)
file(COPY ${FAST_DOUBLE_PARSER_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/external_libs/fast_double_parser)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gpu USE_GPU
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_STATIC_LIB "OFF")
else()
    set(BUILD_STATIC_LIB "ON")
endif()


vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_STATIC_LIB=${BUILD_STATIC_LIB}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES lightgbm AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
