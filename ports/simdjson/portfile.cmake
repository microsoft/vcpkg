include(vcpkg_common_functions)

if(TARGET_TRIPLET MATCHES "^x86")
    message(FATAL_ERROR "simdjson doesn't support x86 architecture.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lemire/simdjson
    REF 352dd5e7faf3000004c6ad5852c119ce3e679939
    SHA512 29c578952d7aa117fe5808ceb2cb686895185d5f53bee3fff6636ac6fe6e50e1cc802499710eda4f233e3c5ff57ebf187ff6658fd5048a59cee8cfd8fca64c1d
    HEAD_REF master
    PATCHES
        fix-cmake.patch
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

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/unofficial-${PORT}
    TARGET_PATH share/unofficial-${PORT}
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
#vcpkg_test_cmake(PACKAGE_NAME ${PORT})
