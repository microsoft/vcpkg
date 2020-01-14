# - Find JXR
# Find the JXR library 
# This module defines
#  JXR_INCLUDE_DIRS, where to find jxrlib/JXRGlue.h
#  JXR_LIBRARIES, the libraries needed to use JXR
#

find_path(JXR_INCLUDE_DIRS
    NAMES JXRGlue.h
    PATH_SUFFIXES jxrlib
)
mark_as_advanced(JXR_INCLUDE_DIRS)

include(SelectLibraryConfigurations)

find_library(JPEGXR_LIBRARY_RELEASE NAMES jpegxr PATH_SUFFIXES lib)
find_library(JPEGXR_LIBRARY_DEBUG NAMES jpegxrd PATH_SUFFIXES lib)
select_library_configurations(JPEGXR)

find_library(JXRGLUE_LIBRARY_RELEASE NAMES jxrglue PATH_SUFFIXES lib)
find_library(JXRGLUE_LIBRARY_DEBUG NAMES jxrglued PATH_SUFFIXES lib)
select_library_configurations(JXRGLUE)

set(JXR_LIBRARIES ${JPEGXR_LIBRARY} ${JXRGLUE_LIBRARY})
mark_as_advanced(JXR_LIBRARIES)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(JXR DEFAULT_MSG JXR_INCLUDE_DIRS JXR_LIBRARIES)
