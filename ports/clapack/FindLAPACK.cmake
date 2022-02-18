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

set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
find_dependency(Threads)

if(UNIX)
  find_library(ADDITIONAL_LAPACK_LIBRARY m)
  set(PTHREAD_LINK_NAME "-pthread")
endif()

if(NOT F2C_LIBRARY)
  find_library(F2C_LIBRARY_RELEASE NAMES f2c libf2c)
  find_library(F2C_LIBRARY_DEBUG NAMES f2cd libf2cd)
  select_library_configurations(F2C)

  #keep a list of "pure" f2c libs, without dependencies
  set(oF2C_LIBRARY_RELEASE ${F2C_LIBRARY_RELEASE})
  set(oF2C_LIBRARY_DEBUG ${F2C_LIBRARY_DEBUG})
  set(oF2C_LIBRARY ${F2C_LIBRARY})

  list(APPEND F2C_LIBRARY ${ADDITIONAL_LAPACK_LIBRARY})
endif()

if(NOT LAPACK_LIBRARY)
  find_library(LAPACK_LIBRARY_RELEASE NAMES lapack)
  find_library(LAPACK_LIBRARY_DEBUG NAMES lapackd)

  #keep a list of "pure" lapack libs, without dependencies
  set(oLAPACK_LIBRARY_RELEASE ${LAPACK_LIBRARY_RELEASE})
  set(oLAPACK_LIBRARY_DEBUG ${LAPACK_LIBRARY_DEBUG})
  select_library_configurations(oLAPACK)

  list(APPEND LAPACK_LIBRARY_RELEASE ${F2C_LIBRARY_RELEASE})
  list(APPEND LAPACK_LIBRARY_DEBUG ${F2C_LIBRARY_DEBUG})

  find_dependency(OpenBLAS)
  get_property(_loc TARGET OpenBLAS::OpenBLAS PROPERTY IMPORTED_IMPLIB_RELEASE)
  if(NOT _loc)
    get_property(_loc TARGET OpenBLAS::OpenBLAS PROPERTY LOCATION_RELEASE)
  endif()
  set(LAPACK_BLAS_LIBRARY_RELEASE ${_loc})
  get_property(_loc TARGET OpenBLAS::OpenBLAS PROPERTY IMPORTED_IMPLIB_DEBUG)
  if(NOT _loc)
    get_property(_loc TARGET OpenBLAS::OpenBLAS PROPERTY LOCATION_DEBUG)
  endif()
  set(LAPACK_BLAS_LIBRARY_DEBUG ${_loc})
  select_library_configurations(LAPACK_BLAS)
  list(APPEND LAPACK_LIBRARY_RELEASE ${LAPACK_BLAS_LIBRARY_RELEASE})
  list(APPEND LAPACK_LIBRARY_DEBUG ${LAPACK_BLAS_LIBRARY_DEBUG})

  select_library_configurations(LAPACK)
  if(UNIX)
    list(APPEND LAPACK_LIBRARY ${PTHREAD_LINK_NAME})
  endif()
endif()

if(NOT F2C_INCLUDE_DIR)
  find_path(F2C_INCLUDE_DIR NAMES f2c.h)
endif()

if(NOT LAPACK_INCLUDE_DIR)
  find_path(LAPACK_INCLUDE_DIR NAMES clapack.h)
endif()

list(APPEND LAPACK_INCLUDE_DIR ${F2C_INCLUDE_DIR})
set(LAPACK_INCLUDE_DIR "${LAPACK_INCLUDE_DIR}" CACHE PATH "" FORCE)
set(LAPACK_INCLUDE_DIRS "${LAPACK_INCLUDE_DIR}" CACHE PATH "" FORCE)
set(CLAPACK_INCLUDE_DIR "${LAPACK_INCLUDE_DIR}" CACHE PATH "" FORCE)
set(CLAPACK_INCLUDE_DIRS "${LAPACK_INCLUDE_DIR}" CACHE PATH "" FORCE)
set(F2C_INCLUDE_DIRS "${F2C_INCLUDE_DIR}" CACHE PATH "" FORCE)

set(LAPACK_DLL_DIR ${LAPACK_INCLUDE_DIR})
list(TRANSFORM LAPACK_DLL_DIR APPEND "/../bin")
message(STATUS "LAPACK_DLL_DIR: ${LAPACK_DLL_DIR}")

if(WIN32)
  find_file(LAPACK_LIBRARY_RELEASE_DLL NAMES lapack.dll PATHS ${LAPACK_DLL_DIR})
  find_file(LAPACK_LIBRARY_DEBUG_FOLDER NAMES lapackd.dll PATHS ${LAPACK_DLL_DIR})
  find_file(F2C_LIBRARY_RELEASE_DLL NAMES f2c.dll libf2c.dll PATHS ${LAPACK_DLL_DIR})
  find_file(F2C_LIBRARY_DEBUG_DLL NAMES f2cd.dll libf2cd.dll PATHS ${LAPACK_DLL_DIR})
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

find_package_handle_standard_args(LAPACK DEFAULT_MSG LAPACK_LIBRARY LAPACK_INCLUDE_DIR)
mark_as_advanced(LAPACK_INCLUDE_DIR LAPACK_LIBRARY)

#TARGETS
if(CLAPACK_FOUND AND NOT TARGET clapack::clapack)
  if(EXISTS "${LAPACK_LIBRARY_RELEASE_DLL}")
    add_library(clapack::clapack SHARED IMPORTED)
    set_target_properties(clapack::clapack PROPERTIES
      IMPORTED_LOCATION_RELEASE                 "${LAPACK_LIBRARY_RELEASE_DLL}"
      IMPORTED_IMPLIB_RELEASE                   "${oLAPACK_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES             "${LAPACK_INCLUDE_DIR}"
      INTERFACE_LINK_LIBRARIES                  "$<$<NOT:$<CONFIG:DEBUG>>:${oF2C_LIBRARY_RELEASE}>;$<$<CONFIG:DEBUG>:${oF2C_LIBRARY_DEBUG}>;$<$<NOT:$<CONFIG:DEBUG>>:${LAPACK_BLAS_LIBRARY_RELEASE}>;$<$<CONFIG:DEBUG>:${LAPACK_BLAS_LIBRARY_DEBUG}>;$<LINK_ONLY:${ADDITIONAL_LAPACK_LIBRARY}>;$<LINK_ONLY:${PTHREAD_LINK_NAME}>"
      IMPORTED_CONFIGURATIONS                   Release
      IMPORTED_LINK_INTERFACE_LANGUAGES         "C")
    if(EXISTS "${LAPACK_LIBRARY_DEBUG_DLL}")
      set_property(TARGET clapack::clapack APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
      set_target_properties(clapack::clapack PROPERTIES
        IMPORTED_LOCATION_DEBUG                 "${LAPACK_LIBRARY_DEBUG_DLL}"
        IMPORTED_IMPLIB_DEBUG                   "${oLAPACK_LIBRARY_DEBUG}")
    endif()
  else()
    add_library(clapack::clapack UNKNOWN IMPORTED)
    set_target_properties(clapack::clapack PROPERTIES
      IMPORTED_LOCATION_RELEASE                 "${oLAPACK_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES             "${LAPACK_INCLUDE_DIR}"
      INTERFACE_LINK_LIBRARIES                  "$<$<NOT:$<CONFIG:DEBUG>>:${oF2C_LIBRARY_RELEASE}>;$<$<CONFIG:DEBUG>:${oF2C_LIBRARY_DEBUG}>;$<$<NOT:$<CONFIG:DEBUG>>:${LAPACK_BLAS_LIBRARY_RELEASE}>;$<$<CONFIG:DEBUG>:${LAPACK_BLAS_LIBRARY_DEBUG}>;$<LINK_ONLY:${ADDITIONAL_LAPACK_LIBRARY}>;$<LINK_ONLY:${PTHREAD_LINK_NAME}>"
      IMPORTED_CONFIGURATIONS                   Release
      IMPORTED_LINK_INTERFACE_LANGUAGES         "C")
    if(EXISTS "${LAPACK_LIBRARY_DEBUG}")
      set_property(TARGET clapack::clapack APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
      set_target_properties(clapack::clapack PROPERTIES
        IMPORTED_LOCATION_DEBUG                 "${oLAPACK_LIBRARY_DEBUG}")
    endif()
  endif()
endif()

# Ensure consistency with both CMake's vanilla as well as lapack-reference's FindLAPACK.cmake module and register the LAPACK::LAPACK target
if(CLAPACK_FOUND AND NOT TARGET LAPACK::LAPACK)
  if(EXISTS "${LAPACK_LIBRARY_RELEASE_DLL}")
    add_library(LAPACK::LAPACK SHARED IMPORTED)
    set_target_properties(LAPACK::LAPACK PROPERTIES
      IMPORTED_LOCATION_RELEASE                 "${LAPACK_LIBRARY_RELEASE_DLL}"
      IMPORTED_IMPLIB_RELEASE                   "${oLAPACK_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES             "${LAPACK_INCLUDE_DIR}"
      INTERFACE_LINK_LIBRARIES                  "$<$<NOT:$<CONFIG:DEBUG>>:${oF2C_LIBRARY_RELEASE}>;$<$<CONFIG:DEBUG>:${oF2C_LIBRARY_DEBUG}>;$<$<NOT:$<CONFIG:DEBUG>>:${LAPACK_BLAS_LIBRARY_RELEASE}>;$<$<CONFIG:DEBUG>:${LAPACK_BLAS_LIBRARY_DEBUG}>;$<LINK_ONLY:${ADDITIONAL_LAPACK_LIBRARY}>;$<LINK_ONLY:${PTHREAD_LINK_NAME}>"
      IMPORTED_CONFIGURATIONS                   Release
      IMPORTED_LINK_INTERFACE_LANGUAGES         "C")
    if(EXISTS "${LAPACK_LIBRARY_DEBUG_DLL}")
      set_property(TARGET LAPACK::LAPACK APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
      set_target_properties(LAPACK::LAPACK PROPERTIES
        IMPORTED_LOCATION_DEBUG                 "${LAPACK_LIBRARY_DEBUG_DLL}"
        IMPORTED_IMPLIB_DEBUG                   "${oLAPACK_LIBRARY_DEBUG}")
    endif()
  else()
    add_library(LAPACK::LAPACK UNKNOWN IMPORTED)
    set_target_properties(LAPACK::LAPACK PROPERTIES
      IMPORTED_LOCATION_RELEASE                 "${oLAPACK_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES             "${LAPACK_INCLUDE_DIR}"
      IMPORTED_CONFIGURATIONS                   Release
      INTERFACE_LINK_LIBRARIES                  "$<$<NOT:$<CONFIG:DEBUG>>:${oF2C_LIBRARY_RELEASE}>;$<$<CONFIG:DEBUG>:${oF2C_LIBRARY_DEBUG}>;$<$<NOT:$<CONFIG:DEBUG>>:${LAPACK_BLAS_LIBRARY_RELEASE}>;$<$<CONFIG:DEBUG>:${LAPACK_BLAS_LIBRARY_DEBUG}>;$<LINK_ONLY:${ADDITIONAL_LAPACK_LIBRARY}>;$<LINK_ONLY:${PTHREAD_LINK_NAME}>"
      IMPORTED_LINK_INTERFACE_LANGUAGES         "C")
    if(EXISTS "${LAPACK_LIBRARY_DEBUG}")
      set_property(TARGET LAPACK::LAPACK APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
      set_target_properties(LAPACK::LAPACK PROPERTIES
        IMPORTED_LOCATION_DEBUG                 "${oLAPACK_LIBRARY_DEBUG}")
    endif()
  endif()
endif()

# Preserve backwards compatibility and also register the 'lapack' target
if(CLAPACK_FOUND AND NOT TARGET lapack)
    add_library(lapack ALIAS LAPACK::LAPACK)
endif()
