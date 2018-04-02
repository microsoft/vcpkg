# - C++ Requests, Curl for People
# This module is a libcurl wrapper written in modern C++.
# It provides an easy, intuitive, and efficient interface to
# a host of networking methods.
#
# Finding this module will define the following variables:
#  CPR_FOUND - True if the core library has been found
#  CPR_LIBRARIES - Path to the core library archive
#  CPR_INCLUDE_DIRS - Path to the include directories. Gives access
#                     to cpr.h, which must be included in every
#                     file that uses this interface
include(FindPackageHandleStandardArgs)

if (WIN32)
	# Find include files
	find_path(
		CPR_INCLUDE_DIR
		NAMES cpr/cpr.h
		PATHS
		$ENV{PROGRAMFILES}/include
		${CPR_ROOT_DIR}/include
		DOC "The directory where cpr/cpr.h resides")

	# Use cpr.lib for static library
	set(CPR_LIBRARY_NAME cpr)

	# Find library files
	find_library(
		CPR_LIBRARY
		NAMES ${CPR_LIBRARY_NAME}
		PATHS
		$ENV{PROGRAMFILES}/lib
		${CPR_ROOT_DIR}/lib)

	unset(CPR_LIBRARY_NAME)
else()
	# Find include files
	find_path(
		CPR_INCLUDE_DIR
		NAMES cpr.h
		PATHS
		/usr/include
		/usr/local/include
		/sw/include
		/opt/local/include
		DOC "The directory where cpr/cpr.h resides")

	# Find library files
	# Try to use static libraries
	find_library(
		CPR_LIBRARY
		NAMES cpr
		PATHS
		/usr/lib64
		/usr/lib
		/usr/local/lib64
		/usr/local/lib
		/sw/lib
		/opt/local/lib
		${GLFW_ROOT_DIR}/lib
		DOC "The GLFW library")
endif()

# Handle REQUIRD argument, define *_FOUND variable
find_package_handle_standard_args(CPR REQUIRED_VARS CPR_LIBRARY CPR_INCLUDE_DIR)

if(CPR_FOUND)
    set(CPR_LIBRARIES ${CPR_LIBRARY})
    set(CPR_INCLUDE_DIRS ${CPR_INCLUDE_DIR})
endif()

# Hide some variables
mark_as_advanced(CPR_INCLUDE_DIR CPR_LIBRARY)