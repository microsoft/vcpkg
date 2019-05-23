if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    include(CMakeFindDependencyMacro)
    find_dependency(Threads)
    find_dependency(unofficial-iconv CONFIG)
    find_dependency(unofficial-gettext CONFIG)
endif()

include("${CMAKE_CURRENT_LIST_DIR}/unofficial-glib-targets.cmake")
