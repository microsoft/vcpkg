#.rst:
# clapack config for vcpkg
# ------------
#
# Find the clapack includes and library.
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This script defines the following variables:
#
# ``CLAPACK_FOUND``
#   True if clapack library found
#
# ``CLAPACK_VERSION``
#   Containing the clapack version tag (manually defined)
#
# ``CLAPACK_INCLUDE_DIR``
#   Location of clapack headers
#
# ``CLAPACK_LIBRARY``
#   List of libraries to link with when using clapack
#
# Result Targets
# ^^^^^^^^^^^^^^
#
# This script defines the following targets:
#
# ``clapack::clapack``
#   Target to use clapack
#
# Compatibility Variables
# ^^^^^^^^^^^^^^^^^^^^^^^
#
# This script defines the following variables for compatibility reasons:
#
# ``F2C_FOUND``
#   True if f2c (fortran-to-c wrap layer) library found
#
# ``F2C_INCLUDE_DIR``
#   Location of clapack headers
#
# ``F2C_LIBRARY``
#   Library containing the fortran-to-c wrap layer, necessary for clapack and automatically included when used
#
# ``LAPACK_FOUND``
#   True if clapack library found
#
# ``LAPACK_VERSION``
#   Containing the clapack version tag (manually defined)
#
# ``LAPACK_INCLUDE_DIR``
#   Location of clapack headers
#
# ``LAPACK_LIBRARY``
#   List of libraries to link with when using clapack
#
# Compatibility Targets
# ^^^^^^^^^^^^^^
#
# This script defines the following targets for compatibility reasons:
#
# ``lapack``
#   Target to use lapack

include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)
include(${CMAKE_ROOT}/Modules/CheckSymbolExists.cmake)
include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
include(${CMAKE_ROOT}/Modules/CMakeFindDependencyMacro.cmake)

set(CLAPACK_VERSION "3.2.1")

if(UNIX)
  find_library(ADDITIONAL_LAPACK_LIBRARY m)
endif()

if(NOT F2C_LIBRARY)
  find_library(F2C_LIBRARY_RELEASE NAMES f2c libf2c)
  find_library(F2C_LIBRARY_DEBUG NAMES f2cd libf2cd)
  list(APPEND F2C_LIBRARY_RELEASE ${ADDITIONAL_LAPACK_LIBRARY})
  list(APPEND F2C_LIBRARY_DEBUG ${ADDITIONAL_LAPACK_LIBRARY})
  select_library_configurations(F2C)
endif()

if(NOT LAPACK_LIBRARY)
  find_library(LAPACK_LIBRARY_RELEASE NAMES lapack)
  find_library(LAPACK_LIBRARY_DEBUG NAMES lapackd)
  list(APPEND LAPACK_LIBRARY_RELEASE ${F2C_LIBRARY_RELEASE})
  list(APPEND LAPACK_LIBRARY_DEBUG ${F2C_LIBRARY_DEBUG})

  if(UNIX AND NOT APPLE)
    find_dependency(OpenBLAS)
    get_property(_loc TARGET OpenBLAS::OpenBLAS PROPERTY LOCATION_RELEASE)
    set(LAPACK_BLAS_LIBRARY_RELEASE ${_loc})
    get_property(_loc TARGET OpenBLAS::OpenBLAS PROPERTY LOCATION_DEBUG)
    set(LAPACK_BLAS_LIBRARY_DEBUG ${_loc})
    list(APPEND LAPACK_LIBRARY_RELEASE ${LAPACK_BLAS_LIBRARY_RELEASE})
    list(APPEND LAPACK_LIBRARY_DEBUG ${LAPACK_BLAS_LIBRARY_DEBUG})
    select_library_configurations(LAPACK_BLAS)
  else()
    find_dependency(BLAS)
    set(LAPACK_LIBRARY_RELEASE ${BLAS_LIBRARIES})
    set(LAPACK_LIBRARY_DEBUG ${BLAS_LIBRARIES})
  endif()

  select_library_configurations(LAPACK)
endif()

if(NOT F2C_INCLUDE_DIR)
  find_path(F2C_INCLUDE_DIR NAMES f2c.h)
endif()

if(NOT LAPACK_INCLUDE_DIR)
  find_path(LAPACK_INCLUDE_DIR NAMES clapack.h)
endif()

list(APPEND LAPACK_INCLUDE_DIR ${F2C_INCLUDE_DIR})
set(LAPACK_INCLUDE_DIRS "${LAPACK_INCLUDE_DIR}" CACHE PATH "" FORCE)
set(CLAPACK_INCLUDE_DIR "${LAPACK_INCLUDE_DIR}" CACHE PATH "" FORCE)
set(CLAPACK_INCLUDE_DIRS "${LAPACK_INCLUDE_DIR}" CACHE PATH "" FORCE)
set(F2C_INCLUDE_DIRS "${F2C_INCLUDE_DIR}" CACHE PATH "" FORCE)

if(WIN32)
  string( REPLACE ".lib" ".dll" LAPACK_LIBRARY_RELEASE_DLL "${LAPACK_LIBRARY_RELEASE}" )
  string( REPLACE ".lib" ".dll" LAPACK_LIBRARY_DEBUG_DLL   "${LAPACK_LIBRARY_DEBUG}" )
  string( REPLACE ".lib" ".dll" F2C_LIBRARY_RELEASE_DLL    "${F2C_LIBRARY_RELEASE}" )
  string( REPLACE ".lib" ".dll" F2C_LIBRARY_DEBUG_DLL      "${F2C_LIBRARY_DEBUG}" )
endif()

set(LAPACK_BLAS_LIBRARY "${LAPACK_BLAS_LIBRARY}" CACHE STRING "" FORCE)
set(F2C_LIBRARIES "${F2C_LIBRARY}" CACHE STRING "" FORCE)
set(LAPACK_VERSION "${CLAPACK_VERSION}" CACHE STRING "" FORCE)
set(LAPACK_LIBRARIES "${LAPACK_LIBRARY}" CACHE STRING "" FORCE)
set(CLAPACK_LIBRARY "${LAPACK_LIBRARY}" CACHE STRING "" FORCE)
set(CLAPACK_LIBRARIES "${LAPACK_LIBRARY}" CACHE STRING "" FORCE)

set(LAPACK_LIBRARY "${LAPACK_LIBRARY}" CACHE STRING "" FORCE)
set(F2C_LIBRARY "${F2C_LIBRARY}" CACHE STRING "" FORCE)
set(LAPACK_LIBRARY_RELEASE "${LAPACK_LIBRARY_RELEASE}" CACHE STRING "" FORCE)
set(LAPACK_LIBRARY_DEBUG "${LAPACK_LIBRARY_DEBUG}" CACHE STRING "" FORCE)
set(F2C_LIBRARY_RELEASE "${F2C_LIBRARY_RELEASE}" CACHE STRING "" FORCE)
set(F2C_LIBRARY_DEBUG "${F2C_LIBRARY_DEBUG}" CACHE STRING "" FORCE)

find_package_handle_standard_args(CLAPACK DEFAULT_MSG CLAPACK_LIBRARY CLAPACK_INCLUDE_DIR)
mark_as_advanced(CLAPACK_INCLUDE_DIR CLAPACK_LIBRARY)

find_package_handle_standard_args(LAPACK  DEFAULT_MSG LAPACK_LIBRARY LAPACK_INCLUDE_DIR)
mark_as_advanced(LAPACK_INCLUDE_DIR LAPACK_LIBRARY)

find_package_handle_standard_args(F2C     DEFAULT_MSG F2C_LIBRARY F2C_INCLUDE_DIR)
mark_as_advanced(F2C_INCLUDE_DIR F2C_LIBRARY)

#TARGETS
if( CLAPACK_FOUND AND NOT TARGET clapack::clapack )
  if( EXISTS "${LAPACK_LIBRARY_RELEASE_DLL}" )
    add_library( clapack::clapack      SHARED IMPORTED )
    target_link_libraries(clapack::clapack INTERFACE ${F2C_LIBRARY})
    if(TARGET OpenBLAS::OpenBLAS)
      target_link_libraries(clapack::clapack INTERFACE OpenBLAS::OpenBLAS)
    endif()
    set_target_properties( clapack::clapack PROPERTIES
      IMPORTED_LOCATION_RELEASE         ${LAPACK_LIBRARY_RELEASE_DLL}
      IMPORTED_IMPLIB                   ${LAPACK_LIBRARY_RELEASE}
      INTERFACE_INCLUDE_DIRECTORIES     ${LAPACK_INCLUDE_DIR}
      IMPORTED_CONFIGURATIONS           Release
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
    if( EXISTS "${LAPACK_LIBRARY_DEBUG_DLL}" )
      set_property( TARGET clapack::clapack APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
      set_target_properties( clapack::clapack PROPERTIES
        IMPORTED_LOCATION_DEBUG           ${LAPACK_LIBRARY_DEBUG_DLL}
        IMPORTED_IMPLIB_DEBUG             ${LAPACK_LIBRARY_DEBUG} )
    endif()
  else()
    add_library( clapack::clapack      UNKNOWN IMPORTED )
    target_link_libraries(clapack::clapack INTERFACE ${F2C_LIBRARY})
    if(TARGET OpenBLAS::OpenBLAS)
      target_link_libraries(clapack::clapack INTERFACE OpenBLAS::OpenBLAS)
    endif()
    set_target_properties( clapack::clapack PROPERTIES
      IMPORTED_LOCATION_RELEASE         ${LAPACK_LIBRARY_RELEASE}
      INTERFACE_INCLUDE_DIRECTORIES     ${LAPACK_INCLUDE_DIR}
      IMPORTED_CONFIGURATIONS           Release
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
    if( EXISTS "${LAPACK_LIBRARY_DEBUG}" )
      set_property( TARGET clapack::clapack APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
      set_target_properties( clapack::clapack PROPERTIES
        IMPORTED_LOCATION_DEBUG           ${LAPACK_LIBRARY_DEBUG} )
    endif()
  endif()
endif()

if( CLAPACK_FOUND AND NOT TARGET lapack )
  if( EXISTS "${LAPACK_LIBRARY_RELEASE_DLL}" )
    add_library( lapack      SHARED IMPORTED )
    target_link_libraries(lapack INTERFACE ${F2C_LIBRARY})
    if(TARGET OpenBLAS::OpenBLAS)
      target_link_libraries(lapack INTERFACE OpenBLAS::OpenBLAS)
    endif()
    set_target_properties( lapack PROPERTIES
      IMPORTED_LOCATION_RELEASE         ${LAPACK_LIBRARY_RELEASE_DLL}
      IMPORTED_IMPLIB                   ${LAPACK_LIBRARY_RELEASE}
      INTERFACE_INCLUDE_DIRECTORIES     ${LAPACK_INCLUDE_DIR}
      IMPORTED_CONFIGURATIONS           Release
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
    if( EXISTS "${LAPACK_LIBRARY_DEBUG_DLL}" )
      set_property( TARGET lapack APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
      set_target_properties( lapack PROPERTIES
        IMPORTED_LOCATION_DEBUG           ${LAPACK_LIBRARY_DEBUG_DLL}
        IMPORTED_IMPLIB_DEBUG             ${LAPACK_LIBRARY_DEBUG} )
    endif()
  else()
    add_library( lapack      UNKNOWN IMPORTED )
    target_link_libraries(lapack INTERFACE ${F2C_LIBRARY})
    if(TARGET OpenBLAS::OpenBLAS)
      target_link_libraries(lapack INTERFACE OpenBLAS::OpenBLAS)
    endif()
    set_target_properties( lapack PROPERTIES
      IMPORTED_LOCATION_RELEASE         ${LAPACK_LIBRARY_RELEASE}
      INTERFACE_INCLUDE_DIRECTORIES     ${LAPACK_INCLUDE_DIR}
      IMPORTED_CONFIGURATIONS           Release
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
    if( EXISTS "${LAPACK_LIBRARY_DEBUG}" )
      set_property( TARGET lapack APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
      set_target_properties( lapack PROPERTIES
        IMPORTED_LOCATION_DEBUG           ${LAPACK_LIBRARY_DEBUG} )
    endif()
  endif()
endif()
