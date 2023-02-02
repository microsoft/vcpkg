include(CMakeFindDependencyMacro)

if(NOT WIN32)
    find_dependency(Threads)
endif()

if(@WITH_ZLIB@)
    find_dependency(ZLIB CONFIG)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/unofficial-sqlite3-targets.cmake)
