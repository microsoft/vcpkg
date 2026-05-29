vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KjellKod/g3log
    REF "${VERSION}"
    SHA512 94074247811d2811bad634714549f59ca4826976e0129160a007229fdc39b6abdb36a5a3f851de64bf9df11fde5838f200c6d5b171004c5c2f2cd5ae4e0eb3ed
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" G3_SHARED_LIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" G3_SHARED_RUNTIME)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dynamic-logging USE_DYNAMIC_LOGGING_LEVELS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DG3_SHARED_LIB=${G3_SHARED_LIB} # Options.cmake
        -DG3_SHARED_RUNTIME=${G3_SHARED_RUNTIME} # Options.cmake
        -DADD_FATAL_EXAMPLE=OFF
        -DADD_G3LOG_BENCH_PERFORMANCE=OFF
        -DADD_G3LOG_UNIT_TEST=OFF
        -DVERSION=${VERSION}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/g3log)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
