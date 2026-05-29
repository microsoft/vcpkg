# Distributed under the OSI-approved BSD 3-Clause License.

#.rst:
# FindCLIPPER
# --------
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module will set the following variables in your project::
#
#  ``CLIPPER_FOUND``
#    True if CLIPPER found on the local system
#
#  ``CLIPPER_INCLUDE_DIRS``
#    Location of CLIPPER header files.
#
#  ``CLIPPER_LIBRARIES``
#    The clipper libraries.
#

include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

if(NOT CLIPPER_INCLUDE_DIR)
  find_path(CLIPPER_INCLUDE_DIR clipper.hpp
    PATH_SUFFIXES polyclipping)
endif()

if(NOT CLIPPER_LIBRARY)
  find_library(CLIPPER_LIBRARY_RELEASE NAMES polyclipping PATHS "${CMAKE_CURRENT_LIST_DIR}/../../lib" NO_DEFAULT_PATH)
  find_library(CLIPPER_LIBRARY_DEBUG NAMES polyclipping PATHS "${CMAKE_CURRENT_LIST_DIR}/../../debug/lib" NO_DEFAULT_PATH)
  select_library_configurations(CLIPPER)
endif()

mark_as_advanced(CLIPPER_LIBRARY CLIPPER_INCLUDE_DIR)

find_package_handle_standard_args(CLIPPER
    REQUIRED_VARS CLIPPER_LIBRARY CLIPPER_INCLUDE_DIR
)

if(CLIPPER_FOUND)
  set(CLIPPER_LIBRARIES ${CLIPPER_LIBRARY})
  set(CLIPPER_INCLUDE_DIRS ${CLIPPER_INCLUDE_DIR})
endif()
