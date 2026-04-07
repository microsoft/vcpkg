# - Config file for the soil2 package
# It defines the following variables
#  SOIL2_INCLUDE_DIRS - include directories for SOIL2
#  SOIL2_LIBRARIES    - libraries to link against

# Load targets
get_filename_component(SOIL2_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
include("${SOIL2_CMAKE_DIR}/soil2Targets.cmake")

# Set properties
get_target_property(SOIL2_INCLUDE_DIRS soil2 INTERFACE_INCLUDE_DIRECTORIES)
set(SOIL2_LIBRARIES soil2)
mark_as_advanced(SOIL2_INCLUDE_DIRS SOIL2_LIBRARIES)
