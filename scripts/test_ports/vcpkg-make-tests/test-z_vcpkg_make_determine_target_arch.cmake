# Test Case 1: Single Target Architecture
set(VCPKG_TARGET_ARCHITECTURE "x86_64")
set(VCPKG_OSX_ARCHITECTURES "x86_64")  # Empty for non-OSX
set(result_arch)
z_vcpkg_make_determine_target_arch(result_arch)
if (NOT "${result_arch}" STREQUAL "x86_64")
    message(FATAL_ERROR "Test 1: z_vcpkg_make_determine_target_arch failed: Expected 'x86_64', got '${result_arch}'")
endif()

# Test Case 2: Universal Architecture (OSX)
if (APPLE)
    set(VCPKG_TARGET_ARCHITECTURE "x86_64")
    set(VCPKG_OSX_ARCHITECTURES "x86_64;arm64")
    set(result_arch)
    z_vcpkg_make_determine_target_arch(result_arch)
    if (NOT "${result_arch}" STREQUAL "universal")
        message(FATAL_ERROR "Test 2: z_vcpkg_make_determine_target_arch failed: Expected 'universal', got '${result_arch}'")
    endif()
endif()

message(STATUS "z_vcpkg_make_determine_target_arch tests passed.")