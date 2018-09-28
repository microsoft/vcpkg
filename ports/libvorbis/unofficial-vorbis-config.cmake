include(CMakeFindDependencyMacro)

find_dependency(unofficial-ogg)

include(${CMAKE_CURRENT_LIST_DIR}/unofficial-vorbis-targets.cmake)
