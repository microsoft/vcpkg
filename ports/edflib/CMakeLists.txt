cmake_minimum_required(VERSION 3.5)

project(EDFlib VERSION 1.21 LANGUAGES C)

option(BUILD_TOOLS "Build EDFlib tools." OFF)

include(GNUInstallDirs)

set(sources edflib.h edflib.c)

add_library(EDFlib ${sources})

if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    target_compile_definitions(EDFlib PRIVATE _LARGEFILE64_SOURCE _LARGEFILE_SOURCE)
endif()

set_target_properties(EDFlib PROPERTIES PUBLIC_HEADER edflib.h)

install(TARGETS EDFlib
    EXPORT EDFlibTargets
    PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

install(EXPORT EDFlibTargets
    FILE unofficial-EDFlibConfig.cmake
    DESTINATION "share/unofficial-EDFlib"
)

if(BUILD_TOOLS)
    include(CheckSymbolExists)

    # https://stackoverflow.com/questions/32816646/can-cmake-detect-if-i-need-to-link-to-libm-when-using-pow-in-c
    if(NOT POW_FUNCTION_EXISTS AND NOT NEED_LINKING_AGAINST_LIBM)
        check_symbol_exists(pow "math.h" POW_FUNCTION_EXISTS)
        if(NOT POW_FUNCTION_EXISTS)
            unset(POW_FUNCTION_EXISTS CACHE)
            list(APPEND CMAKE_REQUIRED_LIBRARIES m)
            check_symbol_exists(pow "math.h" POW_FUNCTION_EXISTS)
            if(POW_FUNCTION_EXISTS)
                set(NEED_LINKING_AGAINST_LIBM True CACHE BOOL "" FORCE)
            else()
                message(FATAL_ERROR "Failed making the pow() function available")
            endif()
        endif()
    endif()

    add_executable(sine_generator sine_generator.c)
    target_link_libraries(sine_generator PRIVATE EDFlib)

    add_executable(sweep_generator sweep_generator.c)
    target_link_libraries(sweep_generator PRIVATE EDFlib)

    add_executable(test_edflib test_edflib.c)
    target_link_libraries(test_edflib PRIVATE EDFlib)

    add_executable(test_generator test_generator.c)
    target_link_libraries(test_generator PRIVATE EDFlib)

    if(NEED_LINKING_AGAINST_LIBM)
        target_link_libraries(sine_generator PRIVATE m)
        target_link_libraries(sweep_generator PRIVATE m)
        target_link_libraries(test_generator PRIVATE m)
    endif()

    install(TARGETS sine_generator sweep_generator test_edflib test_generator
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    )
endif()
