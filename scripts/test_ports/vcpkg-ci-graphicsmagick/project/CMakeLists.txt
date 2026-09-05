cmake_minimum_required(VERSION 3.30)
project(graphicsmagick-test C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(graphicsmagick_pc GraphicsMagick REQUIRED IMPORTED_TARGET)

add_executable(main-pkgconfig main.c)
target_link_libraries(main-pkgconfig PRIVATE PkgConfig::graphicsmagick_pc)

find_program(GM_CONFIG NAMES GraphicsMagick-config REQUIRED)
if(NOT CMAKE_HOST_WIN32)
    execute_process(COMMAND "${GM_CONFIG}" --cppflags --cflags OUTPUT_VARIABLE gm-config-cflags OUTPUT_STRIP_TRAILING_WHITESPACE)
    separate_arguments(gm-config-cflags UNIX_COMMAND "${gm-config-cflags}")
    execute_process(COMMAND "${GM_CONFIG}" --ldflags --libs OUTPUT_VARIABLE gm-config-libs OUTPUT_STRIP_TRAILING_WHITESPACE)
    separate_arguments(gm-config-libs UNIX_COMMAND "${gm-config-libs}")
    string(REGEX REPLACE "(^-|;-)framework;" "\\1framework " gm-config-libs "${gm-config-libs}")

    add_executable(main-gm-config main.c)
    target_compile_options(main-gm-config PRIVATE ${gm-config-cflags})
    target_link_libraries(main-gm-config PRIVATE ${gm-config-libs})
endif()
