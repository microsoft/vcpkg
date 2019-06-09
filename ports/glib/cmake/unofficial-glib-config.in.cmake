include(CMakeFindDependencyMacro)
find_dependency(unofficial-iconv)
if(NOT WIN32)
    find_dependency(Threads)
endif()

include("${CMAKE_CURRENT_LIST_DIR}/unofficial-glib-targets.cmake")
