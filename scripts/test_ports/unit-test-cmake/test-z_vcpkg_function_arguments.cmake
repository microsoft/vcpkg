# these both set `args` in the top level
function(check_function_args start)
    z_vcpkg_function_arguments(out "${start}")
    set(args "${out}" PARENT_SCOPE)
endfunction()
function(check_all_function_args)
    z_vcpkg_function_arguments(out)
    set(args "${out}" PARENT_SCOPE)
endfunction()

unit_test_ensure_fatal_error([[check_function_args(-1)]])
unit_test_ensure_fatal_error([[check_function_args(3)]])
unit_test_ensure_fatal_error([[check_function_args(notanumber)]])
unit_test_check_variable_equal(
    [[check_all_function_args()]]
    args ""
)
unit_test_check_variable_equal(
    [[check_all_function_args("")]]
    args ""
)
unit_test_check_variable_equal(
    [[check_all_function_args("" "")]]
    args ";"
)
unit_test_check_variable_equal(
    [[check_all_function_args("" "" "" "")]]
    args ";;;"
)

unit_test_check_variable_equal(
    [[check_all_function_args(a b c)]]
    args "a;b;c"
)
unit_test_check_variable_equal(
    [[check_function_args(2 a b c)]]
    args "b;c"
)
unit_test_check_variable_equal(
    [[check_function_args(3 a b c)]]
    args "c"
)

unit_test_check_variable_equal(
    [=[check_all_function_args("a;b" [[c\;d]] e)]=]
    args [[a\;b;c\\;d;e]]
)
unit_test_check_variable_equal(
    [=[check_all_function_args("a;b" [[c\;d]] [[e\\;f]])]=]
    args [[a\;b;c\\;d;e\\\;f]]
)
unit_test_check_variable_equal(
    [=[check_function_args(2 "a;b" [[c\;d]] e)]=]
    args [[c\\;d;e]]
)
unit_test_check_variable_equal(
    [=[check_function_args(3 "a;b" [[c\;d]] e)]=]
    args "e"
)
unit_test_check_variable_equal(
    [=[check_function_args(4 "a;b" [[c\;d]] e)]=]
    args ""
)
