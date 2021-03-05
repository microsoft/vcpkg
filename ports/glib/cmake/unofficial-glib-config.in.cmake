include(CMakeFindDependencyMacro)
find_dependency(Iconv)
if(NOT WIN32)
    find_dependency(Threads)
endif()

include("${CMAKE_CURRENT_LIST_DIR}/unofficial-glib-targets.cmake")
