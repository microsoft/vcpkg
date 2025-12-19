
include(CMakeFindDependencyMacro)
if(NOT WIN32)
    find_dependency(Threads)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/unofficial-sqlite3-targets.cmake)

if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    find_package(ICU COMPONENTS uc i18n REQUIRED)
    set_property(TARGET unofficial::sqlite3::sqlite3 APPEND PROPERTY INTERFACE_LINK_LIBRARIES ICU::uc ICU::i18n)
endif()
