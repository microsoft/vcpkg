function(vcpkg_execute_in_download_mode)
    # this allows us to grab the value of the output variables, but pass through the rest of the arguments
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "RESULT_VARIABLE;RESULTS_VARIABLE;OUTPUT_VARIABLE;ERROR_VARIABLE" "")

    set(output_and_error_same OFF)
    set(output_variable_param "")
    set(error_variable_param "")
    set(result_variable_param "")
    set(results_variable_param "")
    if(DEFINED arg_OUTPUT_VARIABLE AND DEFINED arg_ERROR_VARIABLE AND arg_OUTPUT_VARIABLE STREQUAL arg_ERROR_VARIABLE)
        set(output_variable_param OUTPUT_VARIABLE out_err_var)
        set(error_variable_param ERROR_VARIABLE out_err_var)
        set(output_and_error_same ON)
    else()
        if(DEFINED arg_OUTPUT_VARIABLE)
            set(output_variable_param OUTPUT_VARIABLE out_var)
        endif()
        if(DEFINED arg_ERROR_VARIABLE)
            set(error_variable_param ERROR_VARIABLE err_var)
        endif()
    endif()
    if(DEFINED arg_RESULT_VARIABLE)
        set(result_variable_param RESULT_VARIABLE result_var)
    endif()
    if(DEFINED arg_RESULTS_VARIABLE)
        set(results_variable_param RESULTS_VARIABLE results_var)
    endif()

    cmake_language(CALL "${Z_VCPKG_EXECUTE_PROCESS_NAME}"
        ${arg_UNPARSED_ARGUMENTS}
        ${output_variable_param}
        ${error_variable_param}
        ${result_variable_param}
        ${results_variable_param}
    )

    if(output_and_error_same)
        z_vcpkg_forward_output_variable(arg_OUTPUT_VARIABLE out_err_var)
    else()
        z_vcpkg_forward_output_variable(arg_OUTPUT_VARIABLE out_var)
        z_vcpkg_forward_output_variable(arg_ERROR_VARIABLE err_var)
    endif()

    z_vcpkg_forward_output_variable(arg_RESULT_VARIABLE result_var)
    z_vcpkg_forward_output_variable(arg_RESULTS_VARIABLE results_var)
endfunction()
