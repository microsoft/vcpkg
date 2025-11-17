include(CMakeFindDependencyMacro)

find_dependency(cryptopp CONFIG)

include(${CMAKE_CURRENT_LIST_DIR}/unofficial-ripe-targets.cmake)
