cmake_minimum_required(VERSION 3.1 FATAL_ERROR)

project(argon2)
enable_testing()

find_package(Threads REQUIRED)
link_libraries(Threads::Threads)

include_directories(include src)
add_library(argon2_static STATIC src/argon2.c src/core.c src/blake2/blake2b.c src/thread.c src/encoding.c src/ref.c)

add_executable(argon2_test src/test.c)
target_link_libraries(argon2_test argon2_static)
add_test(NAME argon2_test COMMAND argon2_test)

install(TARGETS argon2_static
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
