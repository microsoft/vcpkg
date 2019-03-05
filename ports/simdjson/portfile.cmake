include(vcpkg_common_functions)

if(TARGET_TRIPLET MATCHES "^x86")
    message(FATAL_ERROR "simdjson doesn't support x86 architecture.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lemire/simdjson
    REF 5040840578de7eb5c80c0250585d03b2f096a4ff
    SHA512 be1d07b12a6ed2fdd61862cf8f049209467f1cfd40ad4a73d4da9a31147b83f1e60fc205b64bb311e15fa97432a42aad8a6e3eb5aa0dcc8a0c3afb47b55b6aac
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SIMDJSON_BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSIMDJSON_BUILD_STATIC=${SIMDJSON_BUILD_STATIC}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
#vcpkg_test_cmake(PACKAGE_NAME ${PORT})
