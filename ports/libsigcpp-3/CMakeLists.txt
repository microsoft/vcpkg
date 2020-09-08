# Copyright 2016, The libsigc++ Development Team
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

cmake_minimum_required (VERSION 3.2)

set (SIGCXX_MAJOR_VERSION 2)
set (SIGCXX_MINOR_VERSION 99)
set (SIGCXX_MICRO_VERSION 1)

set (SIGCXX_API_VERSION 3.0)
set (PACKAGE_VERSION ${SIGCXX_MAJOR_VERSION}.${SIGCXX_MINOR_VERSION}.${SIGCXX_MICRO_VERSION})
set (LIBSIGCPP_SOVERSION 0)

option (SIGCXX_DISABLE_DEPRECATED "Disable deprecated" OFF)

project (sigc++)

set( CMAKE_CXX_STANDARD 17 )

# Turn on warnings for MSVC. Remove the CMake default of /W3 because when you
# add /W4, MSVC will complain about two warning level flags. This default
# changed at CMake 3.15 (see 
# https://cmake.org/cmake/help/v3.15/policy/CMP0092.html#policy:CMP0092 for
# more details)
 if (MSVC AND CMAKE_VERSION VERSION_LESS "13.15")
    string(REGEX REPLACE "(^|[ \t])/W[0-9]($|[ \t])" "\\1\\2" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
    string(REGEX REPLACE "(^|[ \t])/W[0-9]($|[ \t])" "\\1\\2" CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS}")
endif()

# Add compiler warning flags & turn warnings into errors
add_compile_options(
    "$<$<OR:$<CXX_COMPILER_ID:MSVC>,$<C_COMPILER_ID:MSVC>>:/W4;/WX>"
    "$<$<OR:$<CXX_COMPILER_ID:GNU>,$<C_COMPILER_ID:GNU>>:-pedantic;-Wall;-Wextra;-Wsuggest-override;-Wshadow;-Wzero-as-null-pointer-constant;-Wformat-security>"
    "$<$<OR:$<CXX_COMPILER_ID:Clang>,$<C_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<C_COMPILER_ID:AppleClang>>:-pedantic;-Wall;-Wextra;-Wshadow;-Wzero-as-null-pointer-constant;-Wformat-security>"
)

set (PROJECT_SOURCE_DIR "${sigc++_SOURCE_DIR}/sigc++")

include_directories (${sigc++_SOURCE_DIR})
include_directories (${sigc++_BINARY_DIR})

configure_file (sigc++config.h.cmake sigc++config.h)

set (prefix ${CMAKE_INSTALL_PREFIX})
set (exec_prefix \${prefix})
set (libdir \${exec_prefix}/lib)
set (datarootdir \${prefix})
set (datadir \${datarootdir})
set (includedir \${prefix}/include)
set (top_srcdir .)
configure_file (sigc++.pc.in sigc++-${SIGCXX_API_VERSION}.pc @ONLY)
configure_file (sigc++-uninstalled.pc.in sigc++-${SIGCXX_API_VERSION}-uninstalled.pc @ONLY)

configure_file(
	"${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
	"${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
 	IMMEDIATE @ONLY)

add_custom_target(uninstall
	COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)


install (FILES
			"${CMAKE_CURRENT_BINARY_DIR}/sigc++config.h"
		DESTINATION
			"${CMAKE_INSTALL_PREFIX}/lib/${PROJECT_NAME}-${SIGCXX_API_VERSION}/include")

install (FILES 
			"${CMAKE_CURRENT_BINARY_DIR}/sigc++-${SIGCXX_API_VERSION}.pc"
		DESTINATION 
			"${CMAKE_INSTALL_PREFIX}/lib/pkgconfig")

#########

set (SOURCE_FILES
	sigc++/connection.cc
	sigc++/signal_base.cc
	sigc++/trackable.cc
	sigc++/functors/slot_base.cc
)

set (SIGCPP_LIB_NAME sigc-${SIGCXX_API_VERSION})

add_library(${SIGCPP_LIB_NAME} ${SOURCE_FILES})

set_property (TARGET ${SIGCPP_LIB_NAME} PROPERTY VERSION ${PACKAGE_VERSION})
set_property(TARGET ${SIGCPP_LIB_NAME}  PROPERTY SOVERSION ${LIBSIGCPP_SOVERSION})
target_compile_definitions( ${SIGCPP_LIB_NAME} PRIVATE -DSIGC_BUILD )

set (INCLUDE_INSTALL_DIR "include/${PROJECT_NAME}-${SIGCXX_API_VERSION}")

install (
	DIRECTORY "${PROJECT_SOURCE_DIR}"
	DESTINATION "${INCLUDE_INSTALL_DIR}"
	FILES_MATCHING PATTERN "*.h"
)

set (PROJECT_CMAKE_NAME ${PROJECT_NAME}-3)

install (
    TARGETS ${SIGCPP_LIB_NAME}
    EXPORT "${PROJECT_CMAKE_NAME}Targets"
    LIBRARY DESTINATION "lib"
    INCLUDES DESTINATION "${INCLUDE_INSTALL_DIR}"
)

#######

set (PROJECT_CMAKE_NAME		"${PROJECT_NAME}-3")
set (VERSION_CONFIG     	"${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CMAKE_NAME}ConfigVersion.cmake")
set (LIBSIGCXX_INCLUDE_DIR	"${CMAKE_INSTALL_PREFIX}/lib/${PROJECT_NAME}-${SIGCXX_API_VERSION}/include")
set (PROJECT_CONFIG     	"${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CMAKE_NAME}Config.cmake")
set (CONFIG_INSTALL_DIR 	"lib/cmake/${PROJECT_CMAKE_NAME}")
set (TARGETS_EXPORT_NAME    "${PROJECT_CMAKE_NAME}Targets")
include (CMakePackageConfigHelpers)

write_basic_package_version_file (
    "${VERSION_CONFIG}"
    VERSION ${PACKAGE_VERSION}
    COMPATIBILITY SameMajorVersion
)

configure_package_config_file (
    "cmake/sigc++-3Config.cmake.in"
    "${PROJECT_CONFIG}"
    INSTALL_DESTINATION "${CONFIG_INSTALL_DIR}"
)

install (
    FILES "${PROJECT_CONFIG}" "${VERSION_CONFIG}"
    DESTINATION "${CONFIG_INSTALL_DIR}"
)

install (
    EXPORT "${TARGETS_EXPORT_NAME}"
    DESTINATION "${CONFIG_INSTALL_DIR}"
)
