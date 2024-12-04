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
    if("${VCPKG_CRT_LINKAGE}" STREQUAL "static")
        message(FATAL_ERROR "This port can only build as a dynamic library, but the triplet \
selects a static library and a static CRT. Building a dynamic library with a static CRT creates \
conditions many developers find surprising, and for which most ports are unprepared, so vcpkg will \
not change VCPKG_LIBRARY_LINKAGE to for you in this case.
For example, on Windows, each DLL will get its own copy of the CRT, meaning such DLLs cannot share \
standard library components over the DLL boundary. On non-Windows, different .sos or .dylibs may \
cause mutually incompatible symbols from different CRT versions to be concurrently loaded.
If you can edit the port calling vcpkg_check_linkage emitting this message, consider adding \
(!static | !static-crt) to the \"supports\" expression so that this combination can fail early.
If you are merely consuming this port, you can consider choosing a triplet which selects a dynamic \
CRT and/or library linkage. If you really know what you're doing, understand the potential \
problems a static CRT with a dynamic library can cause, and are confident that this port safely \
handles that configuration and want to proceed anyway, author a custom triplet which explicitly \
sets VCPKG_LIBRARY_LINKAGE to dynamic and VCPKG_CRT_LINKAGE to static. For example:
    if(\"\${PORT}\" STREQUAL \"${PORT}\")
        set(VCPKG_LIBRARY_LINKAGE dynamic)
        set(VCPKG_CRT_LINKAGE static)
    endif()")
        else()
            message(STATUS "Note: ${PORT} only supports dynamic library linkage. Building dynamic library.")
        endif()
        set(VCPKG_LIBRARY_LINKAGE dynamic PARENT_SCOPE)
    endif()

    if(arg_ONLY_DYNAMIC_CRT AND "${VCPKG_CRT_LINKAGE}" STREQUAL "static")
        message(FATAL_ERROR "${PORT} only supports dynamic crt linkage")
    elseif(arg_ONLY_STATIC_CRT AND "${VCPKG_CRT_LINKAGE}" STREQUAL "dynamic")
        message(FATAL_ERROR "${PORT} only supports static crt linkage")
    endif()
endfunction()
