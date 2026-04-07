#.rst:
# clapack config for vcpkg
# ------------
#
# Find clapack as a valid LAPACK implementation.
#
# The module defines the same outputs as FindLAPACK by cmake

# clapack config is installed together with this module,
# and it handles the BLAS dependency.
find_package(clapack CONFIG REQUIRED)
if(NOT TARGET lapack)
    message(FATAL_ERROR "Target lapack was not created by find_package(clapack)!")
endif()
if(NOT TARGET f2c)
    message(FATAL_ERROR "Target f2c was not created by find_package(clapack)!")
endif()

set(CLAPACK_VERSION "${clapack_VERSION}")
set(LAPACK_VERSION "${CLAPACK_VERSION}")

include(SelectLibraryConfigurations)
include(FindPackageHandleStandardArgs)

get_property(LAPACK_INCLUDE_DIR TARGET lapack PROPERTY INTERFACE_INCLUDE_DIRECTORIES) # Doesn't make much sense but ok. 
get_property(LAPACK_LIBRARY_RELEASE TARGET lapack PROPERTY IMPORTED_LOCATION_RELEASE)
get_property(LAPACK_LIBRARY_DEBUG TARGET lapack PROPERTY IMPORTED_LOCATION_DEBUG)
select_library_configurations(LAPACK)

get_property(LAPACK_F2C_LIBRARY_RELEASE TARGET f2c PROPERTY IMPORTED_LOCATION_RELEASE)
get_property(LAPACK_F2C_LIBRARY_DEBUG TARGET f2c PROPERTY IMPORTED_LOCATION_DEBUG)
select_library_configurations(LAPACK_F2C)

list(APPEND LAPACK_LIBRARIES ${LAPACK_F2C_LIBRARIES} ${BLAS_LIBRARIES})
if(UNIX)
    list(APPEND LAPACK_LIBRARIES "m")
endif()
set(LAPACK95_LIBRARIES "${LAPACK_LIBRARIES}")
set(LAPACK95_FOUND "TRUE")
set(LAPACK_LINKER_FLAGS "")

if(NOT TARGET LAPACK::LAPACK)
    add_library(LAPACK::LAPACK INTERFACE IMPORTED)
    target_link_libraries(LAPACK::LAPACK INTERFACE lapack)
endif()

find_package_handle_standard_args(LAPACK DEFAULT_MSG LAPACK_LIBRARY LAPACK_INCLUDE_DIR)
mark_as_advanced(LAPACK_INCLUDE_DIR LAPACK_LIBRARY)
