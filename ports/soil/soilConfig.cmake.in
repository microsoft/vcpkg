# - Config file for the SOIL package
# It defines the following variables
#  SOIL_INCLUDE_DIRS - include directories for SOIL
#  SOIL_LIBRARIES    - libraries to link against

# Load targets
get_filename_component(SOIL_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
include("${SOIL_CMAKE_DIR}/soilTargets.cmake")

# Set properties
get_target_property(SOIL_INCLUDE_DIRS soil INTERFACE_INCLUDE_DIRECTORIES)
set(SOIL_LIBRARIES soil)
mark_as_advanced(SOIL_INCLUDE_DIRS SOIL_LIBRARIES)
