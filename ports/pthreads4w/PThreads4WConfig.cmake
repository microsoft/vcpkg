#.rst:
# PThreads4W config wrap for vcpkg
# ------------
#
# Find the PThread4W includes and library.
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This script defines the following variables:
#
# ``PThreads4W_FOUND``
#   True if PThreads4W library found
#
# ``PThreads4W_VERSION``
#   Containing the PThreads4W version tag (manually defined)
#
# ``PThreads4W_INCLUDE_DIR``
#   Location of PThreads4W headers
#
# ``PThreads4W_LIBRARY``
#   List of libraries to link with when using PThreads4W (no exception handling)
#
# ``PThreads4W_CXXEXC_LIBRARY``
#   List of libraries to link with when using PThreads4W (C++ exception handling)
#
# ``PThreads4W_STRUCTEXC_LIBRARY``
#   List of libraries to link with when using PThreads4W (struct exception handling)
#
# Result Targets
# ^^^^^^^^^^^^^^^^
#
# This script defines the following targets:
#
# ``PThreads4W::PThreads4W``
#   Target to use PThreads4W (no exception handling)
#
# ``PThreads4W::PThreads4W_CXXEXC``
#   Target to use PThreads4W (C++ exception handling)
#
# ``PThreads4W::PThreads4W_STRUCTEXC``
#   Target to use PThreads4W (struct exception handling)
#

include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)

if(NOT PThreads4W_INCLUDE_DIR)
  find_path(PThreads4W_INCLUDE_DIR NAMES pthread.h PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include" NO_DEFAULT_PATH)
endif()

set(PThreads4W_MAJOR_VERSION 3)
set(PThreads4W_MINOR_VERSION 0)
set(PThreads4W_PATCH_VERSION 0)
set(PThreads4W_VERSION "${PThreads4W_MAJOR_VERSION}.${PThreads4W_MINOR_VERSION}.${PThreads4W_PATCH_VERSION}")

# Allow libraries to be set manually
if(NOT PThreads4W_LIBRARY)
  find_library(PThreads4W_LIBRARY_RELEASE NAMES pthreadVC${PThreads4W_MAJOR_VERSION} PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
  find_library(PThreads4W_LIBRARY_DEBUG NAMES pthreadVC${PThreads4W_MAJOR_VERSION}d PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
  select_library_configurations(PThreads4W)
endif()
if(NOT PThreads4W_CXXEXC_LIBRARY)
  find_library(PThreads4W_CXXEXC_LIBRARY_RELEASE NAMES pthreadVCE${PThreads4W_MAJOR_VERSION} PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
  find_library(PThreads4W_CXXEXC_LIBRARY_DEBUG NAMES pthreadVCE${PThreads4W_MAJOR_VERSION}d PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
  select_library_configurations(PThreads4W_CXXEXC)
endif()
if(NOT PThreads4W_STRUCTEXC_LIBRARY)
  find_library(PThreads4W_STRUCTEXC_LIBRARY_RELEASE NAMES pthreadVSE${PThreads4W_MAJOR_VERSION} PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
  find_library(PThreads4W_STRUCTEXC_LIBRARY_DEBUG NAMES pthreadVSE${PThreads4W_MAJOR_VERSION}d PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
  select_library_configurations(PThreads4W_STRUCTEXC)
endif()

find_package_handle_standard_args(PThreads4W DEFAULT_MSG PThreads4W_LIBRARY PThreads4W_CXXEXC_LIBRARY PThreads4W_STRUCTEXC_LIBRARY PThreads4W_INCLUDE_DIR)
mark_as_advanced(PThreads4W_INCLUDE_DIR PThreads4W_LIBRARY PThreads4W_CXXEXC_LIBRARY PThreads4W_STRUCTEXC_LIBRARY)

set(PThreads4W_DLL_DIR ${PThreads4W_INCLUDE_DIR})
list(TRANSFORM PThreads4W_DLL_DIR APPEND "/../bin")
message(STATUS "PThreads4W_DLL_DIR: ${PThreads4W_DLL_DIR}")
set(PThreads4W_DEBUG_DLL_DIR ${PThreads4W_INCLUDE_DIR})
list(TRANSFORM PThreads4W_DEBUG_DLL_DIR APPEND "/../debug/bin")
message(STATUS "PThreads4W_DEBUG_DLL_DIR: ${PThreads4W_DEBUG_DLL_DIR}")

find_file(PThreads4W_LIBRARY_RELEASE_DLL NAMES pthreadVC${PThreads4W_MAJOR_VERSION}.dll PATHS ${PThreads4W_DLL_DIR})
find_file(PThreads4W_LIBRARY_DEBUG_DLL NAMES pthreadVC${PThreads4W_MAJOR_VERSION}d.dll PATHS ${PThreads4W_DEBUG_DLL_DIR})
find_file(PThreads4W_CXXEXC_LIBRARY_RELEASE_DLL NAMES pthreadVCE${PThreads4W_MAJOR_VERSION}.dll PATHS ${PThreads4W_DLL_DIR})
find_file(PThreads4W_CXXEXC_LIBRARY_DEBUG_DLL NAMES pthreadVCE${PThreads4W_MAJOR_VERSION}d.dll PATHS ${PThreads4W_DEBUG_DLL_DIR})
find_file(PThreads4W_STRUCTEXC_LIBRARY_RELEASE_DLL NAMES pthreadVSE${PThreads4W_MAJOR_VERSION}.dll PATHS ${PThreads4W_DLL_DIR})
find_file(PThreads4W_STRUCTEXC_LIBRARY_DEBUG_DLL NAMES pthreadVSE${PThreads4W_MAJOR_VERSION}d.dll PATHS ${PThreads4W_DEBUG_DLL_DIR})

if( PThreads4W_FOUND AND NOT TARGET PThreads4W::PThreads4W_CXXEXC )
  if( EXISTS "${PThreads4W_CXXEXC_LIBRARY_RELEASE_DLL}" )
    add_library( PThreads4W::PThreads4W_CXXEXC      SHARED IMPORTED )
    set_target_properties( PThreads4W::PThreads4W_CXXEXC PROPERTIES
      IMPORTED_LOCATION_RELEASE         "${PThreads4W_CXXEXC_LIBRARY_RELEASE_DLL}"
      IMPORTED_IMPLIB                   "${PThreads4W_CXXEXC_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES     "${PThreads4W_INCLUDE_DIR}"
      IMPORTED_CONFIGURATIONS           Release
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
    if( EXISTS "${PThreads4W_CXXEXC_LIBRARY_DEBUG_DLL}" )
      set_property( TARGET PThreads4W::PThreads4W_CXXEXC APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
      set_target_properties( PThreads4W::PThreads4W_CXXEXC PROPERTIES
        IMPORTED_LOCATION_DEBUG           "${PThreads4W_CXXEXC_LIBRARY_DEBUG_DLL}"
        IMPORTED_IMPLIB_DEBUG             "${PThreads4W_CXXEXC_LIBRARY_DEBUG}" )
    endif()
  else()
    add_library( PThreads4W::PThreads4W_CXXEXC      UNKNOWN IMPORTED )
    set_target_properties( PThreads4W::PThreads4W_CXXEXC PROPERTIES
      IMPORTED_LOCATION_RELEASE         "${PThreads4W_CXXEXC_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES     "${PThreads4W_INCLUDE_DIR}"
      IMPORTED_CONFIGURATIONS           Release
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
    if( EXISTS "${PThreads4W_CXXEXC_LIBRARY_DEBUG}" )
      set_property( TARGET PThreads4W::PThreads4W_CXXEXC APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
      set_target_properties( PThreads4W::PThreads4W_CXXEXC PROPERTIES
        IMPORTED_LOCATION_DEBUG           "${PThreads4W_CXXEXC_LIBRARY_DEBUG}" )
    endif()
  endif()
endif()

if( PThreads4W_FOUND AND NOT TARGET PThreads4W::PThreads4W_STRUCTEXC )
  if( EXISTS "${PThreads4W_STRUCTEXC_LIBRARY_RELEASE_DLL}" )
    add_library( PThreads4W::PThreads4W_STRUCTEXC      SHARED IMPORTED )
    set_target_properties( PThreads4W::PThreads4W_STRUCTEXC PROPERTIES
      IMPORTED_LOCATION_RELEASE         "${PThreads4W_STRUCTEXC_LIBRARY_RELEASE_DLL}"
      IMPORTED_IMPLIB                   "${PThreads4W_STRUCTEXC_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES     "${PThreads4W_INCLUDE_DIR}"
      IMPORTED_CONFIGURATIONS           Release
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
    if( EXISTS "${PThreads4W_STRUCTEXC_LIBRARY_DEBUG_DLL}" )
      set_property( TARGET PThreads4W::PThreads4W_STRUCTEXC APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
      set_target_properties( PThreads4W::PThreads4W_STRUCTEXC PROPERTIES
        IMPORTED_LOCATION_DEBUG           "${PThreads4W_STRUCTEXC_LIBRARY_DEBUG_DLL}"
        IMPORTED_IMPLIB_DEBUG             "${PThreads4W_STRUCTEXC_LIBRARY_DEBUG}" )
    endif()
  else()
    add_library( PThreads4W::PThreads4W_STRUCTEXC      UNKNOWN IMPORTED )
    set_target_properties( PThreads4W::PThreads4W_STRUCTEXC PROPERTIES
      IMPORTED_LOCATION_RELEASE         "${PThreads4W_STRUCTEXC_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES     "${PThreads4W_INCLUDE_DIR}"
      IMPORTED_CONFIGURATIONS           Release
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
    if( EXISTS "${PThreads4W_STRUCTEXC_LIBRARY_DEBUG}" )
      set_property( TARGET PThreads4W::PThreads4W_STRUCTEXC APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
      set_target_properties( PThreads4W::PThreads4W_STRUCTEXC PROPERTIES
        IMPORTED_LOCATION_DEBUG           "${PThreads4W_STRUCTEXC_LIBRARY_DEBUG}" )
    endif()
  endif()
endif()

if( PThreads4W_FOUND AND NOT TARGET PThreads4W::PThreads4W )
  if( EXISTS "${PThreads4W_LIBRARY_RELEASE_DLL}" )
    add_library( PThreads4W::PThreads4W      SHARED IMPORTED )
    set_target_properties( PThreads4W::PThreads4W PROPERTIES
      IMPORTED_LOCATION_RELEASE         "${PThreads4W_LIBRARY_RELEASE_DLL}"
      IMPORTED_IMPLIB                   "${PThreads4W_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES     "${PThreads4W_INCLUDE_DIR}"
      IMPORTED_CONFIGURATIONS           Release
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
    if( EXISTS "${PThreads4W_LIBRARY_DEBUG_DLL}" )
      set_property( TARGET PThreads4W::PThreads4W APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
      set_target_properties( PThreads4W::PThreads4W PROPERTIES
        IMPORTED_LOCATION_DEBUG           "${PThreads4W_LIBRARY_DEBUG_DLL}"
        IMPORTED_IMPLIB_DEBUG             "${PThreads4W_LIBRARY_DEBUG}" )
    endif()
  else()
    add_library( PThreads4W::PThreads4W      UNKNOWN IMPORTED )
    set_target_properties( PThreads4W::PThreads4W PROPERTIES
      IMPORTED_LOCATION_RELEASE         "${PThreads4W_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES     "${PThreads4W_INCLUDE_DIR}"
      IMPORTED_CONFIGURATIONS           Release
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
    if( EXISTS "${PThreads4W_LIBRARY_DEBUG}" )
      set_property( TARGET PThreads4W::PThreads4W APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
      set_target_properties( PThreads4W::PThreads4W PROPERTIES
        IMPORTED_LOCATION_DEBUG           "${PThreads4W_LIBRARY_DEBUG}" )
    endif()
  endif()
endif()
