function(unit_test_check_variable_equal utcve_test utcve_variable utcve_value)
    cmake_language(EVAL CODE "${utcve_test}")
    if(NOT DEFINED "${utcve_variable}")
        message(FATAL_ERROR "${utcve_test} failed to set ${utcve_variable};
    expected: \"${utcve_value}\"")
    endif()
    if(NOT "${${utcve_variable}}" STREQUAL "${utcve_value}")
        message(FATAL_ERROR "${utcve_test} resulted in the wrong value;
    expected: \"${utcve_value}\"
    actual  : \"${${utcve_variable}}\"")
    endif()
endfunction()

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if("vcpkg-list" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-vcpkg_list.cmake")
endif()
