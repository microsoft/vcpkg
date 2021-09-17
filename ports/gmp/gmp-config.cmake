# Compute the installation prefix relative to this file.
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
if(_IMPORT_PREFIX STREQUAL "/")
  set(_IMPORT_PREFIX "")
endif()

find_library(GMP_LIBRARY_DEBUG NAMES libgmp  gmp  NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_IMPORT_PREFIX}/debug" NO_DEFAULT_PATH REQUIRED)
find_library(GMP_LIBRARY_RELEASE NAMES libgmp gmp NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_IMPORT_PREFIX}" NO_DEFAULT_PATH REQUIRED)

add_library(gmp::gmp UNKNOWN IMPORTED)
target_include_directories(gmp::gmp INTERFACE ${_IMPORT_PREFIX}/include)
set_property(TARGET gmp::gmp APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(gmp::gmp PROPERTIES
   IMPORTED_LOCATION_DEBUG ${GMP_LIBRARY_DEBUG}
)

set_property(TARGET gmp::gmp APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(gmp::gmp PROPERTIES
   IMPORTED_LOCATION_RELEASE ${GMP_LIBRARY_RELEASE}
)