vcpkg_download_distfile(PATCH_JSON_SCHEMA_VALIDATOR_PR_315
    URLS https://github.com/pboettch/json-schema-validator/commit/0034c113477f83c28d4380de1ee189c25b1168e6.patch
    SHA512 5c165b50813b0d9937ff0eb4d4a81e2d1e77718ac3b0d02b93931c8eddb4e06e4fae1822c5cc97a5b01c995916a29d0af03fcbcd8f059cb29cfeb0e2371b15e3
    FILENAME 0034c113477f83c28d4380de1ee189c25b1168e6.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pboettch/json-schema-validator
    REF "${VERSION}"
    SHA512 6d207031acdb94c44f96ff6346dccaf98f2c9d3619d71e419ddabff548ea34d50e8eb103622c99ae28ecb7fddedd687b297e5ad934aa0106c58ac59fc4d65ea9
    HEAD_REF master
    PATCHES
        "${PATCH_JSON_SCHEMA_VALIDATOR_PR_315}"
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
