# Test cases for z_vcpkg_convert_to_msys_path
set(test_cases
    "C:/path/to/file" "/c/path/to/file"
    "D:\\another\\path" "/d/another/path"
)

# Function to run a test and verify the result
function(run_and_verify_test input expected_output)
    z_vcpkg_convert_to_msys_path(result "${input}")
    if(NOT result STREQUAL "${expected_output}")
        message(FATAL_ERROR "Test failed: Input '${input}' expected '${expected_output}', got '${result}'")
    endif()
endfunction()

# Run tests for z_vcpkg_convert_to_msys_path
foreach(input expected_output IN LISTS test_cases)
    run_and_verify_test("${input}" "${expected_output}")
endforeach()