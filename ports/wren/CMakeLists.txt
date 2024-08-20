# CMake taken from https://github.com/walterschell/wren/blob/cmake/CMakeLists.txt

# Need transitive dependencies introduced in 2.8.12
cmake_minimum_required(VERSION 2.8.12)

project(Wren LANGUAGES "C")

set(wren_warning_flags "-Wall" "-Wextra" "-Werror" "-Wno-unused-parameter")     

IF (WIN32)
    ADD_DEFINITIONS (-D_CRT_SECURE_NO_WARNINGS )
ENDIF ()

set(opt_DIR "src/optional")
set(vm_DIR "src/vm")

# TODO: Don't glob
file(GLOB opt_SRCS ${opt_DIR}/*.c)
file(GLOB vm_SRCS ${vm_DIR}/*.c)

set(wren_SRCS ${vm_SRCS} ${opt_SRCS})

add_library(wren ${wren_SRCS})

target_include_directories(wren PUBLIC src/include PRIVATE src/vm src/optional)

target_link_libraries(wren INTERFACE m)

target_compile_options(wren PRIVATE "-Wall")

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(wren PUBLIC -DDEBUG)
endif()


INSTALL (TARGETS wren
    RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
    ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)


IF (NOT DEFINED SKIP_INSTALL_HEADERS)
    INSTALL(
        FILES
            src/include/wren.h
            src/include/wren.hpp
        DESTINATION include
    )
ENDIF ()
