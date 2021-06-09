vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simdjson/simdjson
    REF e9b893ff1b13c6a70135827c62b3f3d65938d135 # v0.9.6
    HEAD_REF master
    SHA512 977b92ffae7219680f3d8567b1911b0d17ac1143a2ba58d7a4007cdcbf42dca6362853fcf3c3caf4af2029bc5f6a3cb8fab6139050a9d8539e8e4c7df646837d
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        no-deprecated SIMDJSON_DISABLE_DEPRECATED_API
        threads       SIMDJSON_ENABLE_THREADS
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSIMDJSON_DEVELOPMENT_CHECKS=OFF
        -DSIMDJSON_DEVELOPER_MODE=OFF
        -DSIMDJSON_GOOGLE_BENCHMARKS=OFF
        -DSIMDJSON_COMPETITION=OFF
        -DSIMDJSON_ENABLE_FUZZING=OFF
        -DSIMDJSON_CXXOPTS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/simdjson.h
        "#if SIMDJSON_USING_LIBRARY"
        "#if 1"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)