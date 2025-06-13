# Return the max value of a list.
#
# param OUTPUT_VARIABLE - number, required, output variable. The max value in the list.
# param TYPE - string, optional. Type of numbers to be compared. Defaults to INTEGER.
# param VALUES - list<string>, required. List of values to be compared.
function(vcpkg_max)

    set(one_value_args_ OUTPUT_VARIABLE TYPE)
    set(multi_value_args_ VALUES)
    cmake_parse_arguments(vcpkg_max "" "${one_value_args_}" "${multi_value_args_}" ${ARGN})
    if (NOT vcpkg_max_OUTPUT_VARIABLE)
        message(FATAL_ERROR "vcpkg_max(): Missing required argument 'OUTPUT_VARIABLE'")
    endif()
    if (NOT vcpkg_max_VALUES)
        message(FATAL_ERROR "vcpkg_max(): Missing required argument 'VALUES'")
    endif()

    # Can be expanded to support other types, if needed
    set(allowed_types_ "INTEGER")
    if (vcpkg_max_TYPE)
        if (NOT "${vcpkg_max_TYPE}" IN_LIST allowed_types_)
            list(JOIN allowed_types_ " | " allowed_types_list_string_)
            message(FATAL_ERROR "vcpkg_max(): Invalid TYPE -'${vcpkg_max_TYPE}'. Allowed values are [${allowed_types_list_string_}]")
        endif()
    else()
        set(vcpkg_max_TYPE "INTEGER") # default to INTEGER if not specified
    endif()

    if (vcpkg_max_TYPE STREQUAL "INTEGER")
        set(max_value_ 0)
        foreach (value_ IN LISTS vcpkg_max_VALUES)
            string(STRIP "${value_}" parsed_value_)
            if (NOT parsed_value_ MATCHES "^[0-9]+$")
                message(FATAL_ERROR "vcpkg_max(): Expected number, got '${parsed_value_}'")
            endif()
            if (parsed_value_ GREATER max_value_)
                set(max_value_ "${parsed_value_}")
            endif()
        endforeach()

        set(${vcpkg_max_OUTPUT_VARIABLE} "${max_value_}" PARENT_SCOPE)
        return()
    endif()

endfunction()
