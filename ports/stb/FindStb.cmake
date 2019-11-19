# Distributed under the OSI-approved BSD 3-Clause License.

#.rst:
# FindStb
# ------------
#
# Find the Stb include headers.
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module defines the following variables:
#
# ``Stb_FOUND``
#   True if Stb library found
#
# ``Stb_INCLUDE_DIR``
#   Location of Stb headers
#

include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)

if(NOT Stb_INCLUDE_DIR)
  find_path(Stb_INCLUDE_DIR NAMES stb_image.h PATHS ${Stb_DIR} PATH_SUFFIXES include)
endif()

find_package_handle_standard_args(Stb DEFAULT_MSG Stb_INCLUDE_DIR)
mark_as_advanced(Stb_INCLUDE_DIR)
