# Named expected values
string(COMPARE EQUAL "1" "1" crosscompiling)
string(COMPARE EQUAL "1" "0" native)

unit_test_check_variable_equal(
    [[ z_vcpkg_make_get_crosscompiling(result --host=HHH --build=BBB) ]]
    result "${crosscompiling}"
)

unit_test_check_variable_equal(
    [[ z_vcpkg_make_get_crosscompiling(result) ]]
    result "${native}"
)

unit_test_check_variable_equal(
    [[ z_vcpkg_make_get_crosscompiling(result --host=BBB --build=BBB) ]]
    result "${native}"
)

unit_test_check_variable_equal(
    [[ z_vcpkg_make_get_crosscompiling(result --build=HHH --host=HHH) ]]
    result "${native}"
)

unit_test_check_variable_equal(
    [[ z_vcpkg_make_get_crosscompiling(result --host=HHH) ]]
    result "${crosscompiling}"
)

unit_test_check_variable_equal(
    [[ z_vcpkg_make_get_crosscompiling(result --build=BBB) ]]
    result "${crosscompiling}"
)

unit_test_check_variable_equal(
    [[ z_vcpkg_make_get_crosscompiling(result --host=HHH --build=BBB) ]]
    result "${crosscompiling}"
)

unit_test_check_variable_equal(
    [[ z_vcpkg_make_get_crosscompiling(result --build=BBB --host=HHH) ]]
    result "${crosscompiling}"
)

if(NOT VCPKG_CROSSCOMPILING)
    z_vcpkg_make_get_configure_triplets(configure_triplets)
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_crosscompiling(result ${configure_triplets}) ]]
        result "${native}"
    )
endif()