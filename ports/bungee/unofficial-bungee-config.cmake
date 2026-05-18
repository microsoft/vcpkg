include(CMakeFindDependencyMacro)
find_dependency(Eigen3 CONFIG)
find_dependency(pffft CONFIG)

include("${CMAKE_CURRENT_LIST_DIR}/unofficial-bungee-targets.cmake")

check_required_components(unofficial-bungee)