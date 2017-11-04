cmake_minimum_required(VERSION 2.8.11)

#######################################
#         PROJECT INFORMATION         #
#-------------------------------------#
# This CMakeLists.txt file is for the #
# IAPWS-IF97 thermodynamic library    #
# written by Ian Bell and Jeff        #
# Henning. The following  section     #
# contains project and version        #
# information.                        #
#######################################

# Project name
set(project_name "IF97")
set(app_name ${project_name})
project(${project_name})

if(IF97_BUILD_TARGETS)
    add_library(IF97 IF97.cpp)

    install(TARGETS IF97
	RUNTIME DESTINATION bin
	ARCHIVE DESTINATION lib
	LIBRARY DESTINATION lib
    )
    
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        install(FILES IF97.h DESTINATION include)
    endif()
else()
    SET(CMAKE_BUILD_TYPE Release)
endif()

#########################################################################
#                              WRAPPER MODULES                          #
#-----------------------------------------------------------------------#
# Wrapper module compilation should be flagged from the command line.   #
# Each wrapper should set(IF97_FLAG ON) to indicate a module was built. #
# If no module is specified on the command line, the IF97_FLAG is not   #
# set and the default test program is built.                            #
#########################################################################

#########################
#  MATHCAD PRIME MODULE #
#########################
	
if (IF97_PRIME_MODULE)
    set(IF97_FLAG ON)
    if(NOT WIN32)
      message(FATAL_ERROR "IF97_PRIME_MODULE can only be used on windows host")
    endif()
    IF( "${IF97_PRIME_ROOT}" STREQUAL "")
        message(FATAL_ERROR "You must provide the path to MathCAD Prime Root directory using something like -DIF97_PRIME_ROOT=\"C:/Program Files/PTC/Mathcad Prime 3.1\"")
    else()
        message(STATUS "IF97_PRIME_ROOT: ${IF97_PRIME_ROOT}")
    endif()
	FILE(GLOB_RECURSE IF97_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/wrapper/Mathcad/includes/*.h")
    include_directories("${IF97_PRIME_ROOT}/Custom Functions" "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/wrapper/Mathcad/includes")
    add_library(IF97 SHARED ${IF97_HEADERS} "${CMAKE_CURRENT_SOURCE_DIR}/IF97.h" "${CMAKE_CURRENT_SOURCE_DIR}/wrapper/MathCAD/IF97.cpp")
    target_link_libraries(IF97 "${IF97_PRIME_ROOT}/Custom Functions/mcaduser.lib")
    SET_TARGET_PROPERTIES(IF97 PROPERTIES LINK_FLAGS "/ENTRY:\"DllEntryPoint\"")
    set_target_properties(IF97 PROPERTIES SUFFIX ".dll" PREFIX "")
#    install (TARGETS IF97 DESTINATION "${IF97_INSTALL_PREFIX}/MathCADPrime")
#    install (FILES "${CMAKE_CURRENT_SOURCE_DIR}/wrappers/MathCAD/if97_validation.mcdx" DESTINATION MathCADPrime)
endif()

#########################
#   MATHCAD 15 MODULE   #
#########################

if (IF97_MATHCAD15_MODULE)
    set(IF97_FLAG ON)
    if(NOT WIN32)
      message(FATAL_ERROR "IF97_MATHCAD15_MODULE can only be used on windows host")
    endif()
    IF( "${IF97_MATHCAD15_ROOT}" STREQUAL "")
        message(FATAL_ERROR "You must provide the path to MathCAD 15 Root directory using something like -DIF97_MATHCAD15_ROOT=\"C:/Program Files (x86)/Mathcad/Mathcad 15\"")
    else()
        message(STATUS "IF97_MATHCAD15_ROOT: ${IF97_MATHCAD15_ROOT}")
    endif()
	FILE(GLOB_RECURSE IF97_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/wrapper/Mathcad/includes/*.h")
    include_directories("${IF97_MATHCAD15_ROOT}/userefi/microsft/include" "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/wrapper/Mathcad/includes")
    add_library(IF97 SHARED ${IF97_HEADERS} "${CMAKE_CURRENT_SOURCE_DIR}/IF97.h" "${CMAKE_CURRENT_SOURCE_DIR}/wrapper/MathCAD/IF97.cpp")
    target_link_libraries(IF97 "${IF97_MATHCAD15_ROOT}/userefi/microsft/lib/mcaduser.lib")
    SET_TARGET_PROPERTIES(IF97 PROPERTIES LINK_FLAGS "/ENTRY:\"DllEntryPoint\"")
    set_target_properties(IF97 PROPERTIES SUFFIX ".dll" PREFIX "")
 #   install (TARGETS IF97 DESTINATION "${IF97_INSTALL_PREFIX}/MathCAD15")
 #   install (FILES "${CMAKE_CURRENT_SOURCE_DIR}/wrappers/MathCAD/if97_validation.xmcdz" DESTINATION MathCAD15)
 #   install (FILES "${CMAKE_CURRENT_SOURCE_DIR}/wrappers/MathCAD/if97_EN.xml" DESTINATION MathCAD15)
endif()

#########################
# TEST MODULE (DEFAULT) #
#########################

if (NOT IF97_FLAG)
    message(STATUS "Stand-alone IF97 Test.")
	add_executable(IF97 "${CMAKE_CURRENT_SOURCE_DIR}/IF97.cpp")
endif()
