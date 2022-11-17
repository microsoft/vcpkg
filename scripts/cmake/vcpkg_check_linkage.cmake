function(vcpkg_check_linkage)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "ONLY_STATIC_LIBRARY;ONLY_DYNAMIC_LIBRARY;ONLY_DYNAMIC_CRT;ONLY_STATIC_CRT"
        ""
        ""
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(arg_ONLY_STATIC_LIBRARY AND arg_ONLY_DYNAMIC_LIBRARY)
        message(FATAL_ERROR "Requesting both ONLY_STATIC_LIBRARY and ONLY_DYNAMIC_LIBRARY; this is an error.")
    endif()
    if(arg_ONLY_STATIC_CRT AND arg_ONLY_DYNAMIC_CRT)
        message(FATAL_ERROR "Requesting both ONLY_STATIC_CRT and ONLY_DYNAMIC_CRT; this is an error.")
    endif()

    if(arg_ONLY_STATIC_LIBRARY AND "${VCPKG_LIBRARY_LINKAGE}" STREQUAL "dynamic")
        message(STATUS "Note: ${PORT} only supports static library linkage. Building static library.")
        set(VCPKG_LIBRARY_LINKAGE static PARENT_SCOPE)
    elseif(arg_ONLY_DYNAMIC_LIBRARY AND "${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
        message(STATUS "Note: ${PORT} only supports dynamic library linkage. Building dynamic library.")
        if("${VCPKG_CRT_LINKAGE}" STREQUAL "static")
            message(FATAL_ERROR "Refusing to build unexpected dynamic library against the static CRT.
    If this is desired, please configure your triplet to directly request this configuration.")
        endif()
        set(VCPKG_LIBRARY_LINKAGE dynamic PARENT_SCOPE)
    endif()

    if(arg_ONLY_DYNAMIC_CRT AND "${VCPKG_CRT_LINKAGE}" STREQUAL "static")
        message(FATAL_ERROR "${PORT} only supports dynamic crt linkage")
    elseif(arg_ONLY_STATIC_CRT AND "${VCPKG_CRT_LINKAGE}" STREQUAL "dynamic")
        message(FATAL_ERROR "${PORT} only supports static crt linkage")
    endif()
endfunction()
