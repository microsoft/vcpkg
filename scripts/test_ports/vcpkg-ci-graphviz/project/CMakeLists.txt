cmake_minimum_required(VERSION 3.30)
project(graphviz-test)


find_package(graphviz CONFIG REQUIRED)

add_executable(simple-cmake "${GRAPHVIZ_PATH}/dot.demo/simple.c")
target_link_libraries(simple-cmake PRIVATE graphviz::gvc graphviz::cgraph)


find_package(PkgConfig REQUIRED)
pkg_check_modules(PC_LIBGVC libgvc IMPORTED_TARGET REQUIRED)

add_executable(simple-pkgconfig "${GRAPHVIZ_PATH}/dot.demo/simple.c")
target_link_libraries(simple-pkgconfig PRIVATE PkgConfig::PC_LIBGVC)


# Validate all imported targets in CMake generation step.
get_directory_property(imported_targets IMPORTED_TARGETS)
foreach(target IN LISTS imported_targets)
    string(MAKE_C_IDENTIFIER "${target}" id)
    add_executable(check-${id} EXCLUDE_FROM_ALL "placeholder.c")
    target_link_libraries(check-${id} PRIVATE ${target})
endforeach()
set_source_files_properties("placeholder.c" PROPERTIES GENERATED 1)
