cmake_minimum_required(VERSION 3.1 FATAL_ERROR)

project(argon2)
enable_testing()

set(ARGON2_VERSION 20210625)

option(BUILD_SHARED_LIBS "Build using shared libraries" ON)
option(OPTIMIZATIONS "Build with optimizations" OFF)

if ((CMAKE_CXX_COMPILER_ID MATCHES "Clang")
 OR (CMAKE_CXX_COMPILER_ID STREQUAL "GNU"))
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden")
endif()

find_package(Threads REQUIRED)
link_libraries(Threads::Threads)

include_directories(include src)

set (ARGON2_SRC
    "src/argon2.c"
    "src/core.c"
    "src/blake2/blake2b.c"
    "src/thread.c"
    "src/encoding.c"
    )

if (OPTIMIZATIONS)
    set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

    message(STATUS "Checking support for hardware optimization:")
    try_compile(WITH_OPTIMIZATIONS
        ${CMAKE_CURRENT_BINARY_DIR}/optimization
        SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/opt.c
        CMAKE_FLAGS -DINCLUDE_DIRECTORIES=${CMAKE_CURRENT_SOURCE_DIR}/include
        OUTPUT_VARIABLE OUTPUT_TEST_SUPPORT_OPTIMIZATION)

    message(STATUS "Build with hardware optimization? ${WITH_OPTIMIZATIONS}")

else (OPTIMIZATIONS)
    set(WITH_OPTIMIZATIONS FALSE)
endif()

if (WITH_OPTIMIZATIONS)
    list(APPEND ARGON2_SRC "src/opt.c")
else()
    list(APPEND ARGON2_SRC "src/ref.c")
endif()

add_library(argon2 ${ARGON2_SRC})
target_compile_definitions(argon2 PUBLIC "A2_VISCTL")

set(ARGON2_HEADERS
    include/argon2.h
)

add_executable(argon2_test src/test.c)
target_link_libraries(argon2_test argon2)
add_test(NAME argon2_test COMMAND argon2_test)

if (NOT ARGON2_SKIP_HEADERS)
    install(FILES ${ARGON2_HEADERS} DESTINATION include)
endif ()

configure_file ("${CMAKE_SOURCE_DIR}/argon2.pc.in" "${PROJECT_BINARY_DIR}/libargon2.pc" @ONLY)
install (FILES "${CMAKE_CURRENT_BINARY_DIR}/libargon2.pc" DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig")

install(TARGETS argon2
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
