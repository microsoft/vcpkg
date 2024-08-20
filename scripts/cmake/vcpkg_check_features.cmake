function(z_vcpkg_check_features_last_feature out_var features_name features_list)
    list(LENGTH features_list features_length)
    math(EXPR features_length_mod_2 "${features_length} % 2")
    if(NOT features_length_mod_2 EQUAL 0)
        message(FATAL_ERROR "vcpkg_check_features has an incorrect number of arguments to ${features_name}")
    endif()

    math(EXPR last_feature "${features_length} / 2 - 1")
    set("${out_var}" "${last_feature}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_check_features_get_feature idx features_list out_feature_name out_feature_var)
    math(EXPR feature_name_idx "${idx} * 2")
    math(EXPR feature_var_idx "${feature_name_idx} + 1")

    list(GET features_list "${feature_name_idx}" feature_name)
    list(GET features_list "${feature_var_idx}" feature_var)

    set("${out_feature_name}" "${feature_name}" PARENT_SCOPE)
    set("${out_feature_var}" "${feature_var}" PARENT_SCOPE)
endfunction()

function(vcpkg_check_features)
    cmake_parse_arguments(
        PARSE_ARGV 0 "arg"
        ""
        "OUT_FEATURE_OPTIONS;PREFIX"
        "FEATURES;INVERTED_FEATURES"
    )

    if(NOT DEFINED arg_OUT_FEATURE_OPTIONS)
        message(FATAL_ERROR "OUT_FEATURE_OPTIONS must be defined.")
    endif()
    if(NOT DEFINED arg_PREFIX)
        set(prefix "")
    else()
        set(prefix "${arg_PREFIX}_")
    endif()

    set(feature_options)
    set(feature_variables)

    if(NOT DEFINED arg_FEATURES AND NOT DEFINED arg_INVERTED_FEATURES)
        message(DEPRECATION
"calling `vcpkg_check_features` without the `FEATURES` keyword has been deprecated.
    Please add the `FEATURES` keyword to the call.")
        set(arg_FEATURES "${arg_UNPARSED_ARGUMENTS}")
    elseif(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_check_features called with unknown arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()



    z_vcpkg_check_features_last_feature(last_feature "FEATURES" "${arg_FEATURES}")
    if(last_feature GREATER_EQUAL 0)
        foreach(feature_pair_idx RANGE "${last_feature}")
            z_vcpkg_check_features_get_feature("${feature_pair_idx}" "${arg_FEATURES}" feature_name feature_var)

            list(APPEND feature_variables "${feature_var}")
            if(feature_name IN_LIST FEATURES)
                list(APPEND feature_options "-D${feature_var}=ON")
                set("${prefix}${feature_var}" ON PARENT_SCOPE)
            else()
                list(APPEND feature_options "-D${feature_var}=OFF")
                set("${prefix}${feature_var}" OFF PARENT_SCOPE)
            endif()
        endforeach()
    endif()

    z_vcpkg_check_features_last_feature(last_inverted_feature "INVERTED_FEATURES" "${arg_INVERTED_FEATURES}")
    if(last_inverted_feature GREATER_EQUAL 0)
        foreach(feature_pair_idx RANGE "${last_inverted_feature}")
            z_vcpkg_check_features_get_feature("${feature_pair_idx}" "${arg_INVERTED_FEATURES}" feature_name feature_var)

            list(APPEND feature_variables "${feature_var}")
            if(feature_name IN_LIST FEATURES)
                list(APPEND feature_options "-D${feature_var}=OFF")
                set("${prefix}${feature_var}" OFF PARENT_SCOPE)
            else()
                list(APPEND feature_options "-D${feature_var}=ON")
                set("${prefix}${feature_var}" ON PARENT_SCOPE)
            endif()
        endforeach()
    endif()

    list(SORT feature_variables)
    set(last_variable)
    foreach(variable IN LISTS feature_variables)
        if(variable STREQUAL last_variable)
            message("${Z_VCPKG_BACKCOMPAT_MESSAGE_LEVEL}" "vcpkg_check_features passed the same feature variable multiple times: '${variable}'")
        endif()
        set(last_variable ${variable})
    endforeach()

    set("${arg_OUT_FEATURE_OPTIONS}" "${feature_options}" PARENT_SCOPE)
endfunction()
