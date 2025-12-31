cmake_minimum_required(VERSION 3.30)
project(graphviz-test)


find_package(graphviz CONFIG REQUIRED)

add_executable(simple-cmake "${GRAPHVIZ_PATH}/dot.demo/simple.c")
target_link_libraries(simple-cmake PRIVATE  graphviz::gvc)


find_package(PkgConfig REQUIRED)
pkg_check_modules(PC_LIBGVC libgvc IMPORTED_TARGET REQUIRED)

add_executable(simple-pkgconfig "${GRAPHVIZ_PATH}/dot.demo/simple.c")
target_link_libraries(simple-pkgconfig PRIVATE PkgConfig::PC_LIBGVC)
