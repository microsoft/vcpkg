
include(CMakeFindDependencyMacro)
if(NOT WIN32)
    find_dependency(Threads)
endif()
if("@SQLITE_ENABLE_ICU@" AND "@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    find_dependency(ICU COMPONENTS uc i18n)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/unofficial-sqlite3-targets.cmake)
