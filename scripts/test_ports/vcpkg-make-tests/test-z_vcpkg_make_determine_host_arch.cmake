# Test Case 1: x86_64 Architecture (Windows)
set(ENV{PROCESSOR_ARCHITECTURE} "AMD64")
set(result_arch)
z_vcpkg_make_determine_host_arch(result_arch)
unit_test_check_variable_equal([[]] result_arch "x86_64")

# Test Case 2: i686 Architecture (Windows)
set(ENV{PROCESSOR_ARCHITEW6432} "x86")
set(result_arch)
z_vcpkg_make_determine_host_arch(result_arch)
unit_test_check_variable_equal([[]] result_arch "i686")

unset(ENV{PROCESSOR_ARCHITECTURE})
unset(ENV{PROCESSOR_ARCHITEW6432})
