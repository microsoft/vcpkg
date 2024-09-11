include(CMakeFindDependencyMacro)
find_dependency(nlohmann_json CONFIG)

include("${CMAKE_CURRENT_LIST_DIR}/jigson-targets.cmake")