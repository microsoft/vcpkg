# - try to find HIDAPI library
# from http://www.signal11.us/oss/hidapi/
#
# Cache Variables: (probably not for direct use in your scripts)
#  HIDAPI_INCLUDE_DIR
#  HIDAPI_LIBRARY
#
# Non-cache variables you might use in your CMakeLists.txt:
#  HIDAPI_FOUND
#  HIDAPI_INCLUDE_DIRS
#  HIDAPI_LIBRARIES
#
# Requires these CMake modules:
#  FindPackageHandleStandardArgs (known included with CMake >=2.6.2)
#
# Original Author:
# 2009-2010 Ryan Pavlik <rpavlik@iastate.edu> <abiryan@ryand.net>
# http://academic.cleardefinition.com
# Iowa State University HCI Graduate Program/VRAC
#
# Copyright Iowa State University 2009-2010.
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)

# hacking FindHIDAPI.cmake as hidapi-config.cmake

find_library(HIDAPI_LIBRARY
	NAMES hidapi hidapi-libusb)

find_path(HIDAPI_INCLUDE_DIR
	NAMES hidapi.h
	PATH_SUFFIXES
	hidapi)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(HIDAPI
	DEFAULT_MSG
	HIDAPI_LIBRARY
	HIDAPI_INCLUDE_DIR)

if(HIDAPI_FOUND)
	set(HIDAPI_LIBRARIES "${HIDAPI_LIBRARY}")

	set(HIDAPI_INCLUDE_DIRS "${HIDAPI_INCLUDE_DIR}")
endif()

mark_as_advanced(HIDAPI_INCLUDE_DIR HIDAPI_LIBRARY)
