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
    REF v0.2.0
    SHA512 2b891ff162190cf086fd02d85622dcf419dfcfc638911e2111251689aff02af03b5cffba628bb8d7adb6d399a438d0252bbb203209997e80cc09bb80978d48ff
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SIMDJSON_BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSIMDJSON_BUILD_STATIC=${SIMDJSON_BUILD_STATIC}
    OPTIONS_DEBUG
        -DSIMDJSON_SANITIZE=ON
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
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
