cmake_minimum_required(VERSION 3.7)

project(wxwidgets-example)

add_executable(main WIN32 popup.cpp)

find_package(wxWidgets CONFIG REQUIRED)
target_link_libraries(main PRIVATE wx::wxcore wx::wxbase)

option(USE_WXRC "Use the wxrc resource compiler" ON)
if(USE_WXRC)
    execute_process(
        COMMAND "${wxWidgets_wxrc_EXECUTABLE}" --help
        RESULTS_VARIABLE error_result
    )
    if(error_result)
        message(FATAL_ERROR "Failed to run wxWidgets_wxrc_EXECUTABLE (${wxWidgets_wxrc_EXECUTABLE})")
    endif()
endif()

set(PRINT_VARS "" CACHE STRING "Variables to print at the end of configuration")
foreach(var IN LISTS PRINT_VARS)
    message(STATUS "${var}:=${${var}}")
endforeach()
