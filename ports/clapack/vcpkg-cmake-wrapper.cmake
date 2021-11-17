if(NOT clapack_FOUND)
    set(NEW_ARGS "")
    if("REQUIRED" IN_LIST ARGS)
        list(APPEND NEW_ARGS "REQUIRED")
    endif()
    if("QUIET" IN_LIST ARGS)
        list(APPEND NEW_ARGS "QUIET")
    else()
        message(STATUS "Using Lapack from vcpkg package 'clapack'")
    endif()
    _find_package(clapack CONFIG ${NEW_ARGS})
    if(clapack_FOUND)
        set(LAPACK_FOUND TRUE)
        set(LAPACK95_FOUND TRUE)
        add_library(LAPACK::LAPACK IMPORTED INTERFACE)
        target_link_libraries(LAPACK::LAPACK INTERFACE lapack)
        set(LAPACK_LINKER_FLAGS "")
        set(LAPACK_LIBRARIES "lapack")
        set(LAPACK95_LIBRARIES "")
    endif()
endif()
