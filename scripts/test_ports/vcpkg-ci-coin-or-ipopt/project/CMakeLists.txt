cmake_minimum_required(VERSION 3.30)
project(ipopt-test)

find_package(PkgConfig REQUIRED)
pkg_check_modules(PC_ipopt ipopt IMPORTED_TARGET REQUIRED)

add_executable(simple-pkgconfig
    "${IPOPT_PATH}/examples/Cpp_example/cpp_example.cpp"
    "${IPOPT_PATH}/examples/Cpp_example/MyNLP.cpp"
)
target_link_libraries(simple-pkgconfig PRIVATE PkgConfig::PC_ipopt)
