vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pboettch/json-schema-validator
    REF "${VERSION}"
    SHA512 67d7ffbee7fe0761171d021d66955c760ee02161a1fb3a3eb89e15cb3f320cb4646f5ae7f9c15ddf50b9ad4312dd03af4eb5c88f7427da9426f0ce4afb67ee59
    HEAD_REF master
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DJSON_VALIDATOR_INSTALL=ON
        -DJSON_VALIDATOR_BUILD_TESTS=OFF
        -DJSON_VALIDATOR_BUILD_EXAMPLES=OFF
        -DJSON_VALIDATOR_SHARED_LIBS=${BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME "nlohmann_json_schema_validator" CONFIG_PATH "lib/cmake/nlohmann_json_schema_validator")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
