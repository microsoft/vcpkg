# Test Case 1: Single Target Architecture
set(VCPKG_TARGET_ARCHITECTURE "x86_64")
set(VCPKG_OSX_ARCHITECTURES "x86_64")  # Empty for non-OSX
set(result_arch)
z_vcpkg_make_determine_target_arch(result_arch)
unit_test_check_variable_equal([[]] result_arch "x86_64")

# Test Case 2: Universal Architecture (OSX)
if (VCPKG_HOST_IS_OSX)
    set(VCPKG_TARGET_ARCHITECTURE "x86_64")
    set(VCPKG_OSX_ARCHITECTURES "x86_64;arm64")
    set(result_arch)
    z_vcpkg_make_determine_target_arch(result_arch)
    unit_test_check_variable_equal([[]] result_arch "universal")
endif()
