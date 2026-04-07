cmake_minimum_required(VERSION 3.25)

project(argon2 LANGUAGES C)

option(WITH_OPTIMIZATIONS "Enable SSE2/AVX2/AVX512 optimizations")
option(BUILD_TOOL "Build the tool" OFF)

if(BUILD_SHARED_LIBS)
    if(CMAKE_C_COMPILER_ID MATCHES "Clang" OR CMAKE_C_COMPILER_ID STREQUAL "GNU")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden")
    endif()
endif()

find_package(Threads REQUIRED)

set(ARGON2_HEADERS
    include/argon2.h
)

set (ARGON2_SRC
    src/argon2.c
    src/core.c
    src/blake2/blake2b.c
    src/thread.c
    src/encoding.c
)
if (WITH_OPTIMIZATIONS)
    list(APPEND ARGON2_SRC src/opt.c)
else()
    list(APPEND ARGON2_SRC src/ref.c)
endif()

add_library(libargon2 ${ARGON2_SRC})
set_target_properties(libargon2 PROPERTIES OUTPUT_NAME argon2)
target_include_directories(libargon2 PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include> PRIVATE src)
target_link_libraries(libargon2 PRIVATE Threads::Threads)
if(BUILD_SHARED_LIBS)
    if(WIN32)
        target_compile_definitions(libargon2 PRIVATE "BUILDING_ARGON2_DLL" INTERFACE "USING_ARGON2_DLL")
    else()
        target_compile_definitions(libargon2 PRIVATE "A2_VISCTL")
    endif()
endif()

install(TARGETS libargon2
    EXPORT unofficial-argon2-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

if(BUILD_TOOL)
    add_executable(argon2 src/run.c)
    target_link_libraries(argon2 PRIVATE libargon2)
    set_target_properties(argon2 PROPERTIES PDB_NAME "argon2${CMAKE_EXECUTABLE_SUFFIX}.pdb")

    install(TARGETS argon2 RUNTIME DESTINATION bin)
endif()

install(FILES ${ARGON2_HEADERS} DESTINATION include)

install(EXPORT unofficial-argon2-targets
  NAMESPACE unofficial::argon2::
  DESTINATION "share/unofficial-argon2"
)

function(make_pc_file)
    set(PREFIX "${CMAKE_INSTALL_PREFIX}")
    set(INCLUDE "include")
    set(HOST_MULTIARCH "lib")
    set(EXTRA_LIBS "")
    configure_file ("${CMAKE_SOURCE_DIR}/libargon2.pc.in" "${PROJECT_BINARY_DIR}/libargon2.pc" @ONLY)
endfunction()
make_pc_file()
install (FILES "${CMAKE_CURRENT_BINARY_DIR}/libargon2.pc" DESTINATION "lib/pkgconfig")
