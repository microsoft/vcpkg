set(test_cases
    "amd64" "x86_64"
    "AMD64" "x86_64"
    "x64" "x86_64"
    "x86" "i686"
    "X86" "i686"
    "ARM64" "aarch64"
    "arm64" "aarch64"
    "ARM" "arm"
    "arm" "arm"
    "x86_64" "x86_64"
    "i686" "i686"
    "aarch64" "aarch64"
)

list(LENGTH test_cases num_items)
math(EXPR num_tests "${num_items} / 2 - 1")

foreach(idx RANGE 0 ${num_tests})
    math(EXPR input_idx "${idx} * 2")
    math(EXPR output_idx "${idx} * 2 + 1")
    list(GET test_cases ${input_idx} input)
    list(GET test_cases ${output_idx} expected)

    set(result_arch)
    z_vcpkg_make_determine_arch(result_arch ${input})
    unit_test_check_variable_equal([[]] result_arch "${expected}")
endforeach()
