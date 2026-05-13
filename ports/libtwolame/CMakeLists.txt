cmake_minimum_required(VERSION 3.20)
project(twolame LANGUAGES C)

include(GNUInstallDirs)

option(BUILD_SHARED_LIBS "Build shared library" OFF)

file(GLOB TWOLAME_SRCS ${TWOLAME_SRC_DIR}/libtwolame/*.c)
file(GLOB TWOLAME_PRIVATE_HDRS ${TWOLAME_SRC_DIR}/libtwolame/*.h)
set(TWOLAME_PUBLIC_HDRS ${TWOLAME_SRC_DIR}/libtwolame/twolame.h)

add_library(twolame ${TWOLAME_SRCS})

target_include_directories(twolame
    PUBLIC  $<BUILD_INTERFACE:${TWOLAME_SRC_DIR}/libtwolame>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    PRIVATE ${TWOLAME_SRC_DIR}/libtwolame
)

target_compile_definitions(twolame PRIVATE LIBTWOLAME_BUILD)
if(BUILD_SHARED_LIBS)
    target_compile_definitions(twolame PRIVATE DLL_EXPORT)
else()
    target_compile_definitions(twolame PUBLIC LIBTWOLAME_STATIC)
endif()

if(MSVC)
    target_compile_definitions(twolame PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()
if(UNIX)
    target_link_libraries(twolame PRIVATE m)
endif()

set_target_properties(twolame PROPERTIES
    C_STANDARD 99
    PUBLIC_HEADER "${TWOLAME_PUBLIC_HDRS}"
)

install(TARGETS twolame
    EXPORT twolame-targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT twolame-targets
    FILE twolameConfig.cmake
    NAMESPACE twolame::
    DESTINATION share/twolame
)

# pkg-config file for FFmpeg's configure
set(_pc_prefix "${CMAKE_INSTALL_PREFIX}")
set(_pc_static_define "")
if(NOT BUILD_SHARED_LIBS)
    set(_pc_static_define "-DLIBTWOLAME_STATIC")
endif()

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/twolame.pc"
"prefix=${_pc_prefix}
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: TwoLAME
Description: Optimised MPEG Audio Layer 2 (MP2) encoder
Version: ${PROJECT_VERSION}
Libs: -L\${libdir} -ltwolame
Cflags: -I\${includedir} ${_pc_static_define}
")

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/twolame.pc"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
