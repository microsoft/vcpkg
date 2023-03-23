function(vcpkg_host_path_list)
    if("${ARGC}" LESS "2")
        message(FATAL_ERROR "vcpkg_host_path_list requires at least two arguments.")
    endif()

    if("${ARGV1}" MATCHES "^ARGV([0-9]*)$|^ARG[CN]$|^CMAKE_CURRENT_FUNCTION|^CMAKE_MATCH_")
        message(FATAL_ERROR "vcpkg_host_path_list does not support the list_var being ${ARGV1}.
    Please use a different variable name.")
    endif()

    if("${ARGV1}" MATCHES [[^ENV\{(.*)\}$]])
        set(list "$ENV{${CMAKE_MATCH_1}}")
        set(env_var ON)
    elseif("${ARGV1}" MATCHES [[^([A-Z]+)\{.*\}$]])
        message(FATAL_ERROR "vcpkg_host_path_list does not support ${CMAKE_MATCH_1} variables;
    only ENV{} and regular variables are supported.")
    else()
        set(list "${${ARGV1}}")
        set(env_var OFF)
    endif()
    set(operation "${ARGV0}")
    set(list_var "${ARGV1}")

    cmake_parse_arguments(PARSE_ARGV 2 arg "" "" "")
    set(bad_items "${arg_UNPARSED_ARGUMENTS}")
    list(FILTER bad_items INCLUDE REGEX "[${VCPKG_HOST_PATH_SEPARATOR}]")
    if(NOT "${bad_items}" STREQUAL "")
        message(FATAL_ERROR "Host path separator (${VCPKG_HOST_PATH_SEPARATOR}) in path; this is unsupported.")
    endif()

    cmake_path(CONVERT "${arg_UNPARSED_ARGUMENTS}" TO_NATIVE_PATH_LIST arguments)
    if("${operation}" STREQUAL "SET")
        set(list "${arguments}")
    elseif("${operation}" MATCHES "^(APPEND|PREPEND)$")
        if("${arguments}" STREQUAL "")
            # do nothing
        elseif("${list}" STREQUAL "")
            set(list "${arguments}")
        elseif("${operation}" STREQUAL "PREPEND")
            set(list "${arguments}${VCPKG_HOST_PATH_SEPARATOR}${list}")
        else()
            set(list "${list}${VCPKG_HOST_PATH_SEPARATOR}${arguments}")
        endif()
    else()
        message(FATAL_ERROR "Operation ${operation} not recognized.")
    endif()

    if(env_var)
        set("${list_var}" "${list}")
    else()
        set("${list_var}" "${list}" PARENT_SCOPE)
    endif()
endfunction()
