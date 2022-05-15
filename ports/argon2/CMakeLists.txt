cmake_minimum_required(VERSION 3.1 FATAL_ERROR)

project(argon2)
enable_testing()

option(BUILD_SHARED_LIBS "Build using shared libraries" ON)

find_package(Threads REQUIRED)
link_libraries(Threads::Threads)

include_directories(include src)
add_library(argon2 src/argon2.c src/core.c src/blake2/blake2b.c src/thread.c src/encoding.c src/ref.c)

set(ARGON2_HEADERS
    include/argon2.h
)

add_executable(argon2_test src/test.c)
target_link_libraries(argon2_test argon2)
add_test(NAME argon2_test COMMAND argon2_test)

if (NOT ARGON2_SKIP_HEADERS)
    install(FILES ${ARGON2_HEADERS} DESTINATION include)
endif ()

install(TARGETS argon2
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
