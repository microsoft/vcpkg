cmake_minimum_required(VERSION 3.8)
project(cef CXX)

set(CEF_ROOT ${CMAKE_CURRENT_LIST_DIR})
include(cmake/FindCEF.cmake)
include(cmake/cef_macros.cmake)
add_subdirectory(libcef_dll)

install(TARGETS libcef_dll_wrapper EXPORT libcef-dll-wrapper-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
