include(CMakeFindDependencyMacro)

find_dependency(cryptopp CONFIG)
find_dependency(ZLIB)

include(${CMAKE_CURRENT_LIST_DIR}/unofficial-ripe-targets.cmake)
