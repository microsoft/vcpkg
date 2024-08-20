# NOTE: this function definition is copied directly to scripts/buildsystems/vcpkg.cmake
# do not make changes here without making the same change there.
macro(z_vcpkg_function_arguments OUT_VAR)
    if("${ARGC}" EQUAL 1)
        set(z_vcpkg_function_arguments_FIRST_ARG 0)
    elseif("${ARGC}" EQUAL 2)
        set(z_vcpkg_function_arguments_FIRST_ARG "${ARGV1}")

        if(NOT z_vcpkg_function_arguments_FIRST_ARG GREATER_EQUAL "0" AND NOT z_vcpkg_function_arguments_FIRST_ARG LESS "0")
            message(FATAL_ERROR "z_vcpkg_function_arguments: index (${z_vcpkg_function_arguments_FIRST_ARG}) is not a number")
        elseif(z_vcpkg_function_arguments_FIRST_ARG LESS "0" OR z_vcpkg_function_arguments_FIRST_ARG GREATER ARGC)
            message(FATAL_ERROR "z_vcpkg_function_arguments: index (${z_vcpkg_function_arguments_FIRST_ARG}) out of range")
        endif()
    else()
        # vcpkg bug
        message(FATAL_ERROR "z_vcpkg_function_arguments: invalid arguments (${ARGV})")
    endif()

    set("${OUT_VAR}" "")

    # this allows us to get the value of the enclosing function's ARGC
    set(z_vcpkg_function_arguments_ARGC_NAME "ARGC")
    set(z_vcpkg_function_arguments_ARGC "${${z_vcpkg_function_arguments_ARGC_NAME}}")

    math(EXPR z_vcpkg_function_arguments_LAST_ARG "${z_vcpkg_function_arguments_ARGC} - 1")
    # GREATER_EQUAL added in CMake 3.7
    if(NOT z_vcpkg_function_arguments_LAST_ARG LESS z_vcpkg_function_arguments_FIRST_ARG)
        foreach(z_vcpkg_function_arguments_N RANGE "${z_vcpkg_function_arguments_FIRST_ARG}" "${z_vcpkg_function_arguments_LAST_ARG}")
            string(REPLACE ";" "\\;" z_vcpkg_function_arguments_ESCAPED_ARG "${ARGV${z_vcpkg_function_arguments_N}}")
            # adds an extra ";" on the front
            set("${OUT_VAR}" "${${OUT_VAR}};${z_vcpkg_function_arguments_ESCAPED_ARG}")
        endforeach()
        # and then removes that extra semicolon
        string(SUBSTRING "${${OUT_VAR}}" 1 -1 "${OUT_VAR}")
    endif()
endmacro()
