include(SelectLibraryConfigurations)
include(FindPackageHandleStandardArgs)

# If the user has provided ``WEBP_ROOT``, use it!  Choose items found
# at this location over system locations.
if( EXISTS "$ENV{WEBP_ROOT}" )
  file( TO_CMAKE_PATH "$ENV{WEBP_ROOT}" WEBP_ROOT )
  set( WEBP_ROOT "${WEBP_ROOT}" CACHE PATH "Prefix for WebP installation." )
elseif(EXISTS "$ENV{WEBP_DIR}" )
  file( TO_CMAKE_PATH "$ENV{WEBP_DIR}" WEBP_ROOT )
  set( WEBP_ROOT "${WEBP_ROOT}" CACHE PATH "Prefix for WebP installation." )
endif()

if(NOT WEBP_INCLUDE_DIR)
  FIND_PATH(WEBP_INCLUDE_DIR NAMES webp/decode.h)
endif()

if(NOT WEBP_LIBRARY)
  find_library(WEBP_LIBRARY_RELEASE NAMES webp PATHS ${WEBP_ROOT} PATH_SUFFIXES webp )
  find_library(WEBP_LIBRARY_DEBUG NAMES webpd PATHS ${WEBP_ROOT} PATH_SUFFIXES debug webp webp/debug debug/webp)
  select_library_configurations(WEBP)
endif()

SET(WEBP_LIBRARIES ${WEBP_LIBRARY})
SET(WEBP_INCLUDE_DIRS ${WEBP_INCLUDE_DIR})

find_package_handle_standard_args(WEBP REQUIRED_VARS WEBP_LIBRARY WEBP_INCLUDE_DIR)
