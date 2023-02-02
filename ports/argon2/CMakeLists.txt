cmake_minimum_required(VERSION 3.1 FATAL_ERROR)

project(argon2)

set(ARGON2_VERSION 20190702)

option(BUILD_SHARED_LIBS "Build using shared libraries" ON)

if ((CMAKE_CXX_COMPILER_ID MATCHES "Clang")
 OR (CMAKE_CXX_COMPILER_ID STREQUAL "GNU"))
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden")
endif()

find_package(Threads REQUIRED)

set(ARGON2_HEADERS
    include/argon2.h
)

set (ARGON2_SRC
    "src/argon2.c"
    "src/core.c"
    "src/blake2/blake2b.c"
    "src/thread.c"
    "src/encoding.c"
)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

message(STATUS "Checking support for hardware optimization:")
try_compile(WITH_OPTIMIZATIONS
    ${CMAKE_CURRENT_BINARY_DIR}/optimization
    SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/opt.c
    CMAKE_FLAGS -DINCLUDE_DIRECTORIES=${CMAKE_CURRENT_SOURCE_DIR}/include
    OUTPUT_VARIABLE OUTPUT_TEST_SUPPORT_OPTIMIZATION)

message(STATUS "Build with hardware optimization? ${WITH_OPTIMIZATIONS}")

if (WITH_OPTIMIZATIONS)
    list(APPEND ARGON2_SRC "src/opt.c")
else()
    list(APPEND ARGON2_SRC "src/ref.c")
endif()

add_library(libargon2 ${ARGON2_SRC})
target_include_directories(libargon2 PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include> PRIVATE src)
target_link_libraries(libargon2 Threads::Threads)
target_compile_definitions(libargon2 PUBLIC "A2_VISCTL")
set_target_properties(libargon2 PROPERTIES OUTPUT_NAME argon2)

add_executable(argon2_tool ${ARGON2_SRC} src/run.c)
target_include_directories(argon2_tool PRIVATE include src)
target_compile_definitions(argon2_tool PUBLIC "A2_VISCTL")
target_link_libraries(argon2_tool Threads::Threads)

install(FILES ${ARGON2_HEADERS} DESTINATION include)

set(PREFIX ${CMAKE_INSTALL_PREFIX})
set(UPSTREAM_VER 20190702)
if (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set(EXTRA_LIBS "-lrt -ldl")
endif ()

configure_file ("${CMAKE_SOURCE_DIR}/libargon2.pc.in" "${PROJECT_BINARY_DIR}/libargon2.pc" @ONLY)
install (FILES "${CMAKE_CURRENT_BINARY_DIR}/libargon2.pc" DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig")

install(TARGETS libargon2
    EXPORT unofficial-libargon2
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(EXPORT unofficial-libargon2
  NAMESPACE unofficial::argon2::
  DESTINATION "share/unofficial-libargon2"
)

install(TARGETS argon2_tool
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
