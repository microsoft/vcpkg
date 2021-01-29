# Distributed under the OSI-approved BSD 3-Clause License.
#
#.rst:
# FindCXSparse
# --------
#
# Find the CXSparse library
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# The following variables will be defined:
#
#  ``CXSparse_FOUND``
#    True if CXSparse found on the local system
#
#  ``CXSPARSE_FOUND``
#    True if CXSparse found on the local system
#
#  ``CXSparse_INCLUDE_DIRS``
#    Location of CXSparse header files
#
#  ``CXSPARSE_INCLUDE_DIRS``
#    Location of CXSparse header files
#
#  ``CXSparse_LIBRARIES``
#    List of the CXSparse libraries found
#
#  ``CXSPARSE_LIBRARIES``
#    List of the CXSparse libraries found
#
#

include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)

find_path(CXSPARSE_INCLUDE_DIR NAMES cs.h PATH_SUFFIXES suitesparse)

find_library(CXSPARSE_LIBRARY_RELEASE NAMES cxsparse libcxsparse)
find_library(CXSPARSE_LIBRARY_DEBUG NAMES cxsparsed libcxsparsed)
select_library_configurations(CXSPARSE)

if(CXSPARSE_INCLUDE_DIR)
  set(CXSPARSE_VERSION_FILE ${CXSPARSE_INCLUDE_DIR}/cs.h)
  file(READ ${CXSPARSE_INCLUDE_DIR}/cs.h CXSPARSE_VERSION_FILE_CONTENTS)

  string(REGEX MATCH "#define CS_VER [0-9]+"
    CXSPARSE_MAIN_VERSION "${CXSPARSE_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "#define CS_VER ([0-9]+)" "\\1"
    CXSPARSE_MAIN_VERSION "${CXSPARSE_MAIN_VERSION}")

  string(REGEX MATCH "#define CS_SUBVER [0-9]+"
    CXSPARSE_SUB_VERSION "${CXSPARSE_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "#define CS_SUBVER ([0-9]+)" "\\1"
    CXSPARSE_SUB_VERSION "${CXSPARSE_SUB_VERSION}")

  string(REGEX MATCH "#define CS_SUBSUB [0-9]+"
    CXSPARSE_SUBSUB_VERSION "${CXSPARSE_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "#define CS_SUBSUB ([0-9]+)" "\\1"
    CXSPARSE_SUBSUB_VERSION "${CXSPARSE_SUBSUB_VERSION}")

  set(CXSPARSE_VERSION "${CXSPARSE_MAIN_VERSION}.${CXSPARSE_SUB_VERSION}.${CXSPARSE_SUBSUB_VERSION}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CXSparse
  REQUIRED_VARS CXSPARSE_INCLUDE_DIR CXSPARSE_LIBRARIES
  VERSION_VAR CXSPARSE_VERSION)

set(CXSPARSE_FOUND ${CXSparse_FOUND})
set(CXSPARSE_INCLUDE_DIRS ${CXSPARSE_INCLUDE_DIR})
set(CXSparse_INCLUDE_DIRS ${CXSPARSE_INCLUDE_DIR})
set(CXSparse_LIBRARIES ${CXSPARSE_LIBRARIES})
