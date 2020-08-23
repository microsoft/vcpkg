# Distributed under the OSI-approved BSD 3-Clause License.

#.rst:
# Findrobin-map
# --------
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module will set the following variables in your project::
#
#  ``robin-map_FOUND``
#    True if robin-map found on the local system
#
#  ``robin-map_INCLUDE_DIRS``
#    Location of robin-map header files.
#
#  ``tsl``
#    The robin-map target
#

include(FindPackageHandleStandardArgs)
include(CMakeFindDependencyMacro)
include(SelectLibraryConfigurations)

if(NOT robin-map_INCLUDE_DIR)
  find_path(robin-map_INCLUDE_DIR tsl/robin_map.h)
endif()

mark_as_advanced(robin-map_INCLUDE_DIR)

find_package_handle_standard_args(robin-map
    REQUIRED_VARS robin-map_INCLUDE_DIR
)

set(robin-map_INCLUDE_DIRS ${robin-map_INCLUDE_DIR})

if(robin-map_FOUND AND NOT TARGET tsl)
  add_library(tsl INTERFACE IMPORTED)
  set_target_properties(tsl PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${robin-map_INCLUDE_DIR}")
  set(tsl_FOUND TRUE CACHE BOOL "")
endif()
