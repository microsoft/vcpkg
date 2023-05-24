cmake_minimum_required(VERSION 3.14)

project(tinyexpr LANGUAGES C)

include(CheckSymbolExists)
include(GNUInstallDirs)

if(WIN32 AND BUILD_SHARED_LIBS)
    add_library(tinyexpr tinyexpr.c exports.def)
else()
    add_library(tinyexpr tinyexpr.c)
endif()

target_include_directories(
    tinyexpr
    PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

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

if(NEED_LINKING_AGAINST_LIBM)
    target_link_libraries(tinyexpr PUBLIC m)
endif()

set_target_properties(tinyexpr PROPERTIES PUBLIC_HEADER tinyexpr.h)

install(TARGETS tinyexpr EXPORT unofficial-tinyexpr-config)

install(
    EXPORT unofficial-tinyexpr-config
    NAMESPACE unofficial::tinyexpr::
    DESTINATION share/unofficial-tinyexpr
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
