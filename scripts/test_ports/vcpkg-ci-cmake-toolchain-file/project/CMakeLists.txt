cmake_minimum_required(VERSION 3.30)
project(cmake-toolchain-file-test C CXX)

foreach(var IN ITEMS
    CMAKE_SYSROOT
    CMAKE_FIND_ROOT_PATH
    CMAKE_PREFIX_PATH
    CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES
    CMAKE_SYSTEM_IGNORE_PATH
    CMAKE_FIND_ROOT_PATH_MODE_LIBRARY
)
    list(JOIN "${var}" "\n    " dirs)
    message("" "${var}:\n    ${dirs}\n")
endforeach()

set(CMAKE_FIND_DEBUG_MODE 1)
set(link_libs "")
set(implicit_link_libs "${CMAKE_CXX_IMPLICIT_LINK_LIBRARIES}")
list(REMOVE_ITEM implicit_link_libs ${CMAKE_C_IMPLICIT_LINK_LIBRARIES})
foreach(lib IN LISTS implicit_link_libs)
    if(EXISTS "${lib}")
        message("" "Absolute path: ${lib}\n")
    else()
        string(MAKE_C_IDENTIFIER "${lib}" id)
        find_library(${id}_LIBRARY NAMES "${lib}" NO_CACHE)
        if(NOT ${id}_LIBRARY)
            find_library(${id}_LIBRARY NAMES "${lib}" PATHS ${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES} NO_DEFAULT_PATH NO_CACHE)
        endif()
        list(APPEND link_libs "${${id}_LIBRARY}")
    endif()
endforeach()

# Pull link errors into config step set of log files
try_compile(link_libs_accepted
    SOURCES "${CMAKE_CURRENT_LIST_DIR}/main.c"
    LINK_LIBRARIES ${link_libs}
    LOG_DESCRIPTION "Checking linking with ${link_libs}"
    OUTPUT_VARIABLE output
)
if(NOT link_libs_accepted)
    message(FATAL_ERROR "${output}")
endif()
