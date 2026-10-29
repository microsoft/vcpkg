include(CMakeFindDependencyMacro)
find_dependency(unofficial-libmariadb CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-mariadb-connector-cpp-targets.cmake")
