vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simdjson/simdjson
    REF 3177cd1b5d30eee17940dac05cc8f6eb538bb478 # v3.1.1
    HEAD_REF master
    SHA512 b84764262defcb54b5a485f99272027fc9ba8942be77e87654dccf35b624693eefc778c1ebfdad4f57604b5668d931eb30067feb8495c9275ea03092552c0d7c
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        exceptions SIMDJSON_EXCEPTIONS
        threads    SIMDJSON_ENABLE_THREADS
    INVERTED_FEATURES
        deprecated SIMDJSON_DISABLE_DEPRECATED_API
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SIMDJSON_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSIMDJSON_JUST_LIBRARY=ON
        -DSIMDJSON_SANITIZE_UNDEFINED=OFF
        -DSIMDJSON_SANITIZE=OFF
        -DSIMDJSON_SANITIZE_THREADS=OFF
        -DSIMDJSON_BUILD_STATIC=${SIMDJSON_BUILD_STATIC}
        -DSIMDJSON_DEVELOPMENT_CHECKS=OFF
        -DSIMDJSON_VERBOSE_LOGGING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)