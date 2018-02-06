# - Find WEBP
# Find the WEBP library 
# This module defines
#  WEBP_INCLUDE_DIRS, where to find webp/decode.h
#  WEBP_LIBRARIES, the libraries needed to use WEBP
#

find_path(WEBP_INCLUDE_DIRS
    NAMES webp/decode.h
)
mark_as_advanced(WEBP_INCLUDE_DIRS)

find_library(WEBP_LIBRARY_RELEASE NAMES webp PATH_SUFFIXES lib)
find_library(WEBP_LIBRARY_DEBUG NAMES webpd PATH_SUFFIXES lib)

find_library(WEBPMUX_LIBRARY_RELEASE NAMES webpmux PATH_SUFFIXES lib)
find_library(WEBPMUX_LIBRARY_DEBUG NAMES webpmuxd PATH_SUFFIXES lib)

include(SelectLibraryConfigurations)
select_library_configurations(WEBP)
select_library_configurations(WEBPMUX)

set(WEBP_LIBRARIES ${WEBPMUX_LIBRARY} ${WEBP_LIBRARY})

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(WEBP DEFAULT_MSG WEBP_INCLUDE_DIRS WEBP_LIBRARIES)
