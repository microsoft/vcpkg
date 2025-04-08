unit_test_check_variable_not_equal(
    [[ z_vcpkg_make_determine_host_arch(host_arch) ]]
    host_arch ""
)

if(VCPKG_TARGET_IS_LINUX AND NOT host_arch STREQUAL "arm64")
    block(SCOPE_FOR VARIABLES)
    set(VCPKG_CROSSCOMPILING TRUE)
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "aarch64-linux-gnu-gcc") ]]
        actual "--host=aarch64-linux-gnu"
    )
    set(VCPKG_CROSSCOMPILING FALSE)
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "gcc") ]]
        actual ""
    )
    endblock()
endif()
