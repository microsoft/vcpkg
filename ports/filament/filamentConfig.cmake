include(CMakeFindDependencyMacro)
find_dependency(ZLIB)
find_dependency(PNG)
find_dependency(stb CONFIG)
find_dependency(draco CONFIG)
find_dependency(assimp CONFIG)

include("${CMAKE_CURRENT_LIST_DIR}/filamentTargets.cmake")
