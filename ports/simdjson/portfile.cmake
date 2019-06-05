include(vcpkg_common_functions)

# https://github.com/Microsoft/vcpkg/issues/5418#issuecomment-470519894
if(TARGET_TRIPLET MATCHES "^(x86|arm-)")
    message(FATAL_ERROR "simdjson doesn't support x86 or 32-bit ARM architecture.")
elseif(TARGET_TRIPLET MATCHES "^arm64")
    message(FATAL_ERROR "simdjson doesn't support ARM64 architecture currently.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lemire/simdjson
    REF d2fa086198b77df44e7fa48b25200e118fa81eb0
    SHA512 fe92b65e44502381d286b6a7c949055d185e56e7c244a5ab3086b2fe7da76ce81a966daa2d8459794ff0a911b426b1c77e1fc9ef0d616e20868621b1bb30cf67
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
