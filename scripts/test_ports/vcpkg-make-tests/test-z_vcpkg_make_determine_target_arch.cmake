# Test Case 1: Single Target Architecture
set(VCPKG_TARGET_ARCHITECTURE "x86_64")
set(VCPKG_OSX_ARCHITECTURES "x86_64")  # Empty for non-OSX
set(result_arch)
z_vcpkg_make_determine_target_arch(result_arch)
if (NOT "${result_arch}" STREQUAL "x86_64")
    message(FATAL_ERROR "Target arch test 1 failed: Expected 'x86_64', got '${result_arch}'")
endif()

# Test Case 2: Universal Architecture (OSX)
set(VCPKG_TARGET_ARCHITECTURE "x86_64")
set(VCPKG_OSX_ARCHITECTURES "x86_64;arm64")
set(result_arch)
z_vcpkg_make_determine_target_arch(result_arch)
if (NOT "${result_arch}" STREQUAL "universal")
    message(FATAL_ERROR "Target arch test 2 failed: Expected 'universal', got '${result_arch}'")
endif()

message(STATUS "z_vcpkg_make_determine_target_arch tests passed.")