vcpkg_backup_env_variables(VARS PROCESSOR_ARCHITECTURE PROCESSOR_ARCHITEW6432)

set(result_arch "NOTFOUND")

# Test Case 1: x86_64 Architecture (Windows)
set(ENV{PROCESSOR_ARCHITECTURE} "AMD64")
unit_test_check_variable_equal(
    [[ z_vcpkg_make_determine_host_arch(result_arch) ]]
    result_arch "x86_64"
)

# Test Case 2: i686 Architecture (Windows)
set(ENV{PROCESSOR_ARCHITEW6432} "x86")
unit_test_check_variable_equal(
    [[ z_vcpkg_make_determine_host_arch(result_arch) ]]
    result_arch "i686"
)

vcpkg_restore_env_variables(VARS PROCESSOR_ARCHITECTURE PROCESSOR_ARCHITEW6432)
