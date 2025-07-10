block(SCOPE_FOR VARIABLES)

set(CMAKE_CXX_STANDARD 17)

find_package(PkgConfig REQUIRED)
pkg_check_modules(ggml_pc ggml REQUIRED IMPORTED_TARGET)

set(TEST_TARGET simple-ctx-pkgconfig)
add_executable(${TEST_TARGET} simple-ctx.cpp)
target_link_libraries(${TEST_TARGET} PRIVATE PkgConfig::ggml_pc)

set(TEST_TARGET simple-backend-pkgconfig)
add_executable(${TEST_TARGET} simple-backend.cpp)
target_link_libraries(${TEST_TARGET} PRIVATE PkgConfig::ggml_pc)

endblock()
