message(WARNING "find_package(unofficial-apr) is deprecated.\nUse find_package(apr) instead")
include(CMakeFindDependencyMacro)
find_dependency(apr CONFIG)

if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
    add_library(unofficial::apr::apr-1 INTERFACE IMPORTED)
    target_link_libraries(unofficial::apr::apr-1 INTERFACE apr::apr-1)

    add_library(unofficial::apr::aprapp-1 INTERFACE IMPORTED)
    target_link_libraries(unofficial::apr::aprapp-1 INTERFACE apr::aprapp-1)
else()
    add_library(unofficial::apr::libapr-1 INTERFACE IMPORTED)
    target_link_libraries(unofficial::apr::libapr-1 INTERFACE apr::libapr-1)

    add_library(unofficial::apr::libaprapp-1 INTERFACE IMPORTED)
    target_link_libraries(unofficial::apr::libaprapp-1 INTERFACE apr::libaprapp-1)
endif()
