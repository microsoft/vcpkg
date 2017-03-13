#.rst:
# OGREConfig
# ------------
#
# Dummy OGREConfig to simplify use of OGRE-provided FindOGRE module.
#
# This file is provided as part of the vcpkg port of OGRE .
# It is meant to be found automatically by find_package(OGRE), 
# but then offloads all the real work to the FindOGRE module by temporarly
# adding its directory to CMAKE_MODULE_PATH
#
# See the FindOGRE module to see the defined variables::
#

# Temporarly add the directory in which OGREConfig.cmake is contained to
# get access to the FindOGRE module 
get_filename_component(SELF_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
set(ORIGINAL_CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH ${SELF_DIR})
find_package(OGRE MODULE)

# Leave CMAKE_MODULE_PATH as we found it 
set(CMAKE_MODULE_PATH ${ORIGINAL_CMAKE_MODULE_PATH})

# Handle components
# imported from https://github.com/Kitware/CMake/blob/v3.7.1/Modules/CMakePackageConfigHelpers.cmake#L300
macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

check_required_components(OGRE)