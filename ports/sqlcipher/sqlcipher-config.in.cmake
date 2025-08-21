include(CMakeFindDependencyMacro)

find_dependency(OpenSSL)
if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static" AND NOT WIN32)
    find_dependency(Threads)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/sqlcipher-targets.cmake)
