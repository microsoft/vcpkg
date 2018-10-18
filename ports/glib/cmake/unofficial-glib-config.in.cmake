if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    include(CMakeFindDependencyMacro)
    find_dependency(Threads)
    find_dependency(unofficial-iconv)
endif()

include("${CMAKE_CURRENT_LIST_DIR}/unofficial-glib-targets.cmake")
