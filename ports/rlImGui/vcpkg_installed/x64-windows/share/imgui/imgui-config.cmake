cmake_policy(SET CMP0012 NEW)


####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was imgui-config.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

include(CMakeFindDependencyMacro)

if (OFF)
    if (NOT "")
        find_dependency(glfw3 CONFIG)
    endif()
endif()

if (OFF)
    find_dependency(GLUT)
endif()

if (OFF OR OFF OR OFF)
    find_dependency(SDL3 CONFIG)
endif()

if (OFF)
    find_dependency(Vulkan)
endif()

if (OFF)
    find_dependency(Dawn)
endif()

if (OFF)
    find_dependency(freetype CONFIG)
endif()

if (OFF)
    find_dependency(plutosvg CONFIG)
endif()

if (OFF)
    find_dependency(Allegro CONFIG)
endif()

if (OFF)
    find_dependency(Stb)
endif()

include("${CMAKE_CURRENT_LIST_DIR}/imgui-targets.cmake")
