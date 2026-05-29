file(READ "${CMAKE_CURRENT_LIST_DIR}/usage" usage)
message(WARNING "find_package(${CMAKE_FIND_PACKAGE_NAME}) is deprecated.\n${usage}")

include(CMakeFindDependencyMacro)
find_dependency(unofficial-triangle)
add_library(triangleLib ALIAS unofficial::triangle::triangle)
