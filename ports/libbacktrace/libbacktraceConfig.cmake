if(TARGET libbacktrace::libbacktrace)
    return()
endif()

find_library(LIBBACKTRACE_LIBRARY NAMES backtrace libbacktrace REQUIRED)
find_path(LIBBACKTRACE_INCLUDE_DIR backtrace.h REQUIRED)

add_library(libbacktrace::libbacktrace STATIC IMPORTED)
set_target_properties(libbacktrace::libbacktrace PROPERTIES
    IMPORTED_LOCATION "${LIBBACKTRACE_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${LIBBACKTRACE_INCLUDE_DIR}"
)
