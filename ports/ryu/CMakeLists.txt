cmake_minimum_required(VERSION 3.30)
project(ryu LANGUAGES C)

add_library(ryu
    "ryu/f2s.c"
    "ryu/d2s.c"
    "ryu/d2s.h"
    "ryu/d2s_full_table.h"
    "ryu/d2s_intrinsics.h"
    "ryu/digit_table.h"
    "ryu/common.h"
    "ryu/ryu.h"
)

target_include_directories(ryu PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

add_library(ryu_printf
    "ryu/d2fixed.c"
    "ryu/d2s_intrinsics.h"
    "ryu/d2fixed_full_table.h"
    "ryu/digit_table.h"
    "ryu/common.h"
    "ryu/ryu2.h"
)

target_include_directories(ryu_printf PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

if(NOT "${CMAKE_STATIC_LIBRARY_SUFFIX}" STREQUAL ".lib")
    set_target_properties(ryu PROPERTIES OUTPUT_NAME "libryu")
    set_target_properties(ryu_printf PROPERTIES OUTPUT_NAME "libryu_printf")
endif()

if(INSTALL_HEADERS)
    install(FILES "ryu/ryu.h" "ryu/ryu2.h" DESTINATION "include/ryu")
endif()

install(TARGETS ryu ryu_printf EXPORT ryuTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(EXPORT ryuTargets
    FILE ryuConfig.cmake
    NAMESPACE RYU::
    DESTINATION share/ryu
)
