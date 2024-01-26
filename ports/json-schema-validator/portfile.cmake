vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pboettch/json-schema-validator
    REF "${VERSION}"
    SHA512 6d207031acdb94c44f96ff6346dccaf98f2c9d3619d71e419ddabff548ea34d50e8eb103622c99ae28ecb7fddedd687b297e5ad934aa0106c58ac59fc4d65ea9
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DJSON_VALIDATOR_BUILD_TESTS=OFF
        -DJSON_VALIDATOR_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME nlohmann_json_schema_validator CONFIG_PATH lib/cmake/nlohmann_json_schema_validator)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

