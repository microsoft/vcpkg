# z_vcpkg_cmake_config_fixup_merge(<out_list> <release_list> <debug_list>)
set(release_libs namespace::C++_shared)
set(debug_libs   namespace::C++_shared)
unit_test_check_variable_equal(
    [[z_vcpkg_cmake_config_fixup_merge(merged release_libs debug_libs)]]
    merged "namespace::C++_shared"
)

set(release_libs A)
set(debug_libs   B)
unit_test_check_variable_equal(
    [[z_vcpkg_cmake_config_fixup_merge(merged release_libs debug_libs)]]
    merged [[\$<\$<NOT:\$<CONFIG:DEBUG>>:A>;\$<\$<CONFIG:DEBUG>:B>]]
)

set(release_libs A B)
set(debug_libs   A )
unit_test_check_variable_equal(
    [[z_vcpkg_cmake_config_fixup_merge(merged release_libs debug_libs)]]
    merged [[A;\$<\$<NOT:\$<CONFIG:DEBUG>>:B>]]
)

set(release_libs A )
set(debug_libs   A B)
unit_test_check_variable_equal(
    [[z_vcpkg_cmake_config_fixup_merge(merged release_libs debug_libs)]]
    merged [[A;\$<\$<CONFIG:DEBUG>:B>]]
)

set(release_libs A C)
set(debug_libs   C)
unit_test_check_variable_equal(
    [[z_vcpkg_cmake_config_fixup_merge(merged release_libs debug_libs)]]
    merged [[\$<\$<NOT:\$<CONFIG:DEBUG>>:A>;\$<\$<CONFIG:DEBUG>:C>;\$<\$<NOT:\$<CONFIG:DEBUG>>:C>]]
)

set(release_libs [[\$<\$<NOT:\$<CONFIG:DEBUG>>:A>;\$<\$<CONFIG:DEBUG>:B>]])
set(debug_libs   [[\$<\$<NOT:\$<CONFIG:DEBUG>>:A>;\$<\$<CONFIG:DEBUG>:B>]])
unit_test_check_variable_equal(
    [[z_vcpkg_cmake_config_fixup_merge(merged release_libs debug_libs)]]
    merged [[\$<\$<NOT:\$<CONFIG:DEBUG>>:A>;\$<\$<CONFIG:DEBUG>:B>]]
)

set(release_libs optimized o1 debug d1)
set(debug_libs   optimized o2 debug d2)
unit_test_check_variable_equal(
    [[z_vcpkg_cmake_config_fixup_merge(merged release_libs debug_libs)]]
    merged [[\$<\$<NOT:\$<CONFIG:DEBUG>>:o1>;\$<\$<CONFIG:DEBUG>:d2>]]
)

set(release_libs debug d1 optimized o1)
set(debug_libs   debug d2 optimized o2)
unit_test_check_variable_equal(
    [[z_vcpkg_cmake_config_fixup_merge(merged release_libs debug_libs)]]
    merged [[\$<\$<CONFIG:DEBUG>:d2>;\$<\$<NOT:\$<CONFIG:DEBUG>>:o1>]]
)
