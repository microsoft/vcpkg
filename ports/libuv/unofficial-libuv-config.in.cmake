
if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    include(CMakeFindDependencyMacro)
    find_dependency(Threads)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/unofficial-libuv-targets.cmake)
