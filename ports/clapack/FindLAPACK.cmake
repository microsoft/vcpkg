#.rst:
# clapack config for vcpkg
# ------------
#
# Find clapack as a valid LAPACK implementation.
#
# The module defines the same outputs as FindLAPACK by cmake

include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)
include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)

set(CLAPACK_VERSION "3.2.1")
set(LAPACK_VERSION "${CLAPACK_VERSION}")
#set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
find_package(Threads)

find_package(clapack CONFIG REQUIRED) # This will be found !

if(NOT TARGET lapack)
    message(FATAL_ERROR "Target lapack was not created by find_package(clapack)!")
endif()

if(NOT TARGET LAPACK::LAPACK)
    add_library(LAPACK::LAPACK INTERFACE IMPORTED)
    target_link_libraries(LAPACK::LAPACK INTERFACE lapack)

    set(lib_prop IMPORTED_LOCATION)
    #if(@VCPKG_LIBRARY_LINKAGE@ STREQUAL "dynamic" AND WIN32)
    #    set(lib_prop IMPORTED_IMPLIB)
    #endif()

    get_property(LAPACK_LIBRARY_RELEASE TARGET lapack PROPERTY ${lib_prop}_RELEASE)
    get_property(LAPACK_LIBRARY_DEBUG TARGET lapack PROPERTY ${lib_prop}_DEBUG)

    get_property(LAPACK_INCLUDE_DIR TARGET lapack PROPERTY INTERFACE_INCLUDE_DIRECTORIES) # Doesn't make much sense but ok. 
    select_library_configurations(LAPACK)

    get_property(LAPACK_LINKER_FLAGS_RELEASE TARGET lapack PROPERTY IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE)
    get_property(LAPACK_LINKER_FLAGS_DEBUG TARGET lapack PROPERTY IMPORTED_LINK_INTERFACE_LIBRARIES_DEBUG)
    list(TRANSFORM LAPACK_LINKER_FLAGS_DEBUG PREPEND "$<$<CONFIG:DEBUG>:")
    list(TRANSFORM LAPACK_LINKER_FLAGS_DEBUG APPEND ">")
    list(TRANSFORM LAPACK_LINKER_FLAGS_RELEASE PREPEND "$<$<NOT:$<CONFIG:DEBUG>>:")
    list(TRANSFORM LAPACK_LINKER_FLAGS_RELEASE APPEND ">")

    set(LAPACK_LIBRARIES "${LAPACK_LIBRARIES};${LAPACK_LINKER_FLAGS_DEBUG};${LAPACK_LINKER_FLAGS_RELEASE}")
    set(LAPACK95_LIBRARIES "${LAPACK_LIBRARIES}")
    set(LAPACK95_FOUND "TRUE")
    set(LAPACK_LINKER_FLAGS "${LAPACK_LIBRARIES}")
endif()
find_package_handle_standard_args(LAPACK DEFAULT_MSG LAPACK_LIBRARY LAPACK_INCLUDE_DIR )
mark_as_advanced(LAPACK_INCLUDE_DIR LAPACK_LIBRARY)