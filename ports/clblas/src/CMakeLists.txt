# ########################################################################
# Copyright 2013 Advanced Micro Devices, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ########################################################################

cmake_minimum_required(VERSION 2.8)

#User toggle-able options that can be changed on the command line with -D
option( BUILD_RUNTIME "Build the BLAS runtime library" ON )
option( BUILD_TEST "Build the library testing suite (dependency on google test, Boost, and ACML/NETLIB BLAS)" ON )
option( BUILD_PERFORMANCE "Copy the performance scripts that can measure and graph performance" OFF )
option( BUILD_SAMPLE "Build the sample programs" OFF )
option( BUILD_CLIENT "Build a command line clBLAS client program with a variety of configurable parameters (dependency on Boost)" OFF )
option( BUILD_KTEST "A command line tool for testing single clBLAS kernel" ON )
option( BUILD_SHARED_LIBS "Build shared libraries" ON )

#enable or disable offline compilation for different devices. Currently only Hawaii, Bonaire, Tahiti have the option.
#option( OPENCL_OFFLINE_BUILD_HAWAII_KERNEL "Offline compile the OpenCL kernels for Hawaii device" OFF)
#option( OPENCL_OFFLINE_BUILD_BONAIRE_KERNEL "Offline compile the OpenCL kernels for Bonaire device" OFF)
#option( OPENCL_OFFLINE_BUILD_TAHITI_KERNEL "Offline compile the OpenCL kernels for Tathit device" OFF)
set( OPENCL_OFFLINE_BUILD_HAWAII_KERNEL OFF)
set( OPENCL_OFFLINE_BUILD_BONAIRE_KERNEL OFF)
set( OPENCL_OFFLINE_BUILD_TAHITI_KERNEL OFF)

#if( (OPENCL_OFFLINE_BUILD_HAWAII_KERNEL AND OPENCL_OFFLINE_BUILD_BONAIRE_KERNEL) OR (OPENCL_OFFLINE_BUILD_HAWAII_KERNEL AND OPENCL_OFFLINE_BUILD_TAHITI_KERNEL) OR (OPENCL_OFFLINE_BUILD_BONAIRE_KERNEL AND OPENCL_OFFLINE_BUILD_TAHITI_KERNEL))
#   MESSAGE( WARNING "More than one device is chosen for offline compilation of static kernels. This might result in running out of heap memory with certain driver. Please consider offline compliation for ONE device only." )
#endif( )

#if( NOT OPENCL_OFFLINE_BUILD_HAWAII_KERNEL )
  #use dynamic generated kernels
#  MESSAGE(STATUS "Build dynamic Hawaii kernels.")
#  MESSAGE(STATUS "Check OPENCL_OFFLINE_BUILD_HAWAII_KERNEL to build kernls at compile-time. This will eliminates clBuildProgram() overhead and better kernel performance with certain driver.")
  add_definitions(-DCLBLAS_HAWAII_DYNAMIC_KERNEL)
#else()
#  MESSAGE(STATUS "Build static Hawaii kernels.")
#  MESSAGE(STATUS "Uncheck OPENCL_OFFLINE_BUILD_HAWAII_KERNEL to build kernls at run-time")
#  MESSAGE(STATUS "Please ensure the presence of Hawaii device in the system. With certain driver/compiler flags, this might result in compile-time error.")
#endif( )

#if( NOT OPENCL_OFFLINE_BUILD_BONAIRE_KERNEL )
  #use dynamic generated kernels
#  MESSAGE(STATUS "Build dynamic Bonaire kernels.")
#  MESSAGE(STATUS "Check OPENCL_OFFLINE_BUILD_BONAIRE_KERNEL to build kernls at compile-time. This will eliminates clBuildProgram() overhead and better kernel performance with certain driver.")
  add_definitions(-DCLBLAS_BONAIRE_DYNAMIC_KERNEL)
#else()
#  MESSAGE(STATUS "Build static Bonaire kernels.")
#  MESSAGE(STATUS "Uncheck OPENCL_OFFLINE_BUILD_BONAIRE_KERNEL to build kernls at run-time")
#  MESSAGE(STATUS "Please ensure the presence of Bonaire device in the system. With certain driver/compiler flags, this might result in compile-time error.")
#endif( )

#if( NOT OPENCL_OFFLINE_BUILD_TAHITI_KERNEL )
  #use dynamic generated kernels
#  MESSAGE(STATUS "Build dynamic Tahiti kernels.")
#  MESSAGE(STATUS "Check OPENCL_OFFLINE_BUILD_TAHITI_KERNEL to build kernls at compile-time. This will eliminates clBuildProgram() overhead and better kernel performance with certain driver.")
  add_definitions(-DCLBLAS_TAHITI_DYNAMIC_KERNEL)
#else( )
#  MESSAGE(STATUS "Build static Tahiti kernels.")
#  MESSAGE(STATUS "Uncheck OPENCL_OFFLINE_BUILD_TAHITI_KERNEL to build kernls at run-time")
#  MESSAGE(STATUS "Please ensure the presence of Tahiti device in the system. With certain driver/compiler flags, this might result in compile-time error.")
#endif( )


# Ask the user to verify compiler version. If OpenCL 2.0 is supported. Certain public flags can be user
set( OPENCL_VERSION "1.2" CACHE STRING "The version of OpenCL supported by your driver/device" )
set_property( CACHE OPENCL_VERSION PROPERTY STRINGS 2.0 1.2 1.1 )
message( STATUS "You have confirmed OpenCL ${OPENCL_VERSION} is supported in your system" )

# By default test-correctness is linked and tested against ACML library.
# However, test-correctness can instead use NETLIB as a reference library
# On Mac OSX systems, this must be set to OFF for the build to succeed (due to nesting of FindBLAS code)
if ( APPLE )
	set(CORR_TEST_WITH_ACML OFF CACHE BOOL "Use ACML library in correctness tests")
else ( )
	message(STATUS "CORR_TEST_WITH_ACML set to OFF. Try link with libblas.so")
	set(CORR_TEST_WITH_ACML OFF CACHE BOOL "Use ACML library in correctness tests")
endif( )

if( CMAKE_GENERATOR MATCHES "NMake" )
  option( NMAKE_COMPILE_VERBOSE "Print compile and link strings to the console" OFF )
  if( NMAKE_COMPILE_VERBOSE )
    set( CMAKE_START_TEMP_FILE "" )
    set( CMAKE_END_TEMP_FILE "" )
    set( CMAKE_VERBOSE_MAKEFILE 1 )
  endif( )
endif( )

# If we are on linux, and we wish to link with the netlib BLAS implementation when BUILD_TEST is ON, we need to have a valid fortran compiler
if(BUILD_TEST AND NOT CORR_TEST_WITH_ACML AND NOT WIN32 AND NOT APPLE)
  project(clBLAS Fortran C CXX )
else( )
  project(clBLAS C CXX)
endif( )

# Define a version for the code
if( NOT DEFINED clBLAS_VERSION_MAJOR )
    set( clBLAS_VERSION_MAJOR 2 )
endif( )

if( NOT DEFINED clBLAS_VERSION_MINOR )
    set( clBLAS_VERSION_MINOR 12 )
endif( )

if( NOT DEFINED clBLAS_VERSION_PATCH )
    set( clBLAS_VERSION_PATCH 0 )
endif( )

set( clBLAS_VERSION "${clBLAS_VERSION_MAJOR}.${clBLAS_VERSION_MINOR}.${clBLAS_VERSION_PATCH}")

# Increment this if we break backward compatibility.
set( clBLAS_SOVERSION 2 )

# We have custom written Find* modules now in the root source directory
set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR} )

# On windows, it's convenient to change the default install prefix such that it does NOT point to 'program files' (permissions problems)
# Need to check out CMAKE_RUNTIME_OUTPUT_DIRECTORY variable, and see if that eliminates the need to modify install path
if( WIN32 AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
	set( CMAKE_INSTALL_PREFIX "${PROJECT_BINARY_DIR}/package" CACHE PATH "Install path prefix, prepended onto install directories" FORCE )
endif( )

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
endif()

# These variables are meant to contain string which should be appended to the installation paths
# of library and executable binaries, respectively.  They are meant to be user configurable/overridable.
set( SUFFIX_LIB_DEFAULT "" )
set( SUFFIX_BIN_DEFAULT "" )

if(TARGET_PLATFORM EQUAL 32 OR TARGET_PLATFORM EQUAL 64)
    set(TARGET_PLATFORM ${TARGET_PLATFORM} CACHE STRING "Target platform type (32-bit or 64-bit)" FORCE)
else()
    if(CMAKE_SIZEOF_VOID_P MATCHES 8)
        set(TARGET_PLATFORM "64" CACHE STRING "Target platform type (32-bit or 64-bit)" FORCE)
    else()
        set(TARGET_PLATFORM "32" CACHE STRING "Target platform type (32-bit or 64-bit)" FORCE)
    endif()
endif()

message(STATUS "Target platform: ${TARGET_PLATFORM}-bit")
if(TARGET_PLATFORM EQUAL 32)
    set(_arch "x86" INTERNAL)
    set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS FALSE)
else()
    set(_arch "x86_64" INTERNAL)
    set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS TRUE)
    if( NOT APPLE )
        set( SUFFIX_LIB_DEFAULT "64" )
    endif( )
endif()

set( SUFFIX_LIB ${SUFFIX_LIB_DEFAULT} CACHE STRING "String to append to 'lib' install path" )
set( SUFFIX_BIN ${SUFFIX_BIN_DEFAULT} CACHE STRING "String to append to 'bin' install path" )

if( MSVC_IDE )
    set_property( GLOBAL PROPERTY USE_FOLDERS TRUE )
endif( )

# add the math library for Linux
if( UNIX )
    set(MATH_LIBRARY "m")
    set(THREAD_LIBRARY "pthread")
endif()

# set the path to specific OpenCL compiler
set( OPENCL_COMPILER_DIR "OPENCL COMPILER PATH" CACHE PATH "OPENCL COMPILER PATH")
if ( ${OPENCL_COMPILER_DIR} STREQUAL "OPENCL COMPILER PATH")
    message( STATUS "Using default OpenCL Compiler")
	  set(ENV_PATH "$ENV{PATH}")
else ()
    message( STATUS "OPENCL COMPILER: ${OPENCL_COMPILER_DIR}")
	if(UNIX)
	  set(ENV_PATH "${OPENCL_COMPILER_DIR}")
	else()
	  set(ENV_PATH "${OPENCL_COMPILER_DIR}")
	endif()
endif()

# Find the BLAS library
# TODO: maybe this could be written using the FindBLAS module in the future
if( BUILD_TEST )
	if(NOT CORR_TEST_WITH_ACML)
	    if(APPLE)
			find_library(BLAS_LIBRARIES Accelerate HINTS /System/Library/Frameworks/Accelerate.framework)
		       	MARK_AS_ADVANCED(BLAS_LIBRARIES)
		       	message(STATUS "Using Accelerate framework on Mac OS-X")
	    else()
			find_package( Netlib COMPONENTS BLAS REQUIRED )
        endif()
		else( )
		# Find ACML BLAS implementation
		# platform dependent ACML subdirectory
		if (WIN32)
			set(ACML_SUBDIR ifort${TARGET_PLATFORM}_mp)
		else()
		   set(ACML_SUBDIR gfortran${TARGET_PLATFORM}_mp)
		endif()

		find_path(ACML_INCLUDE_DIRS acml.h
			HINTS
				${ACML_ROOT}/include
				${ACML_ROOT}/${ACML_SUBDIR}/include
				$ENV{ACML_ROOT}/include
                                $ENV{ACML_ROOT}/${ACML_SUBDIR}/include
		)

		if( ACML_INCLUDE_DIRS )
		else()
			message(WARNING "Cannot find acml.h")
		endif()

		if( UNIX )
			find_library(ACML_LIBRARIES acml_mp
				HINTS
					${ACML_ROOT}/lib
					${ACML_ROOT}/${ACML_SUBDIR}/lib
					$ENV{ACML_ROOT}/lib
                                        $ENV{ACML_ROOT}/${ACML_SUBDIR}/lib
			)
			find_library(_acml_mv_library acml_mv
				HINTS
					${ACML_ROOT}/lib
					${ACML_ROOT}/${ACML_SUBDIR}/lib
					$ENV{ACML_ROOT}/lib
                                        $ENV{ACML_ROOT}/${ACML_SUBDIR}/lib
			)
			mark_as_advanced(_acml_mv_library)
		endif( )

		if(WIN32)
			find_library(ACML_LIBRARIES libacml_mp_dll
				HINTS
					${ACML_ROOT}/lib
					${ACML_ROOT}/${ACML_SUBDIR}/lib
					$ENV{ACML_ROOT}/lib
                                        $ENV{ACML_ROOT}/${ACML_SUBDIR}/lib
			)
		endif( )

		if( NOT ACML_LIBRARIES )
			message(WARNING "Cannot find libacml")
		endif( )

		if(ACML_INCLUDE_DIRS AND ACML_LIBRARIES)
			if(_acml_mv_library)
				list(APPEND ACML_LIBRARIES ${_acml_mv_library})
			endif()
			message(STATUS "Found ACML: ${ACML_LIBRARIES}")
			set(ACML_FOUND TRUE BOOL "Found the ACML package")
		endif()
		mark_as_advanced(ACML_FOUND ACML_INCLUDE_DIRS ACML_LIBRARIES)

	endif( )
endif( )

if( BUILD_CLIENT )
    if( NETLIB_FOUND )
    else( )
        message( WARNING "Not find Netlib; BUILD_CLIENT needs the Netlib CBLAS library" )
    endif()
endif()


# This will define OPENCL_FOUND
find_package( OpenCL ${OPENCL_VERSION} )
set( OPENCL_FOUND ${OpenCL_FOUND})
set( OPENCL_LIBRARIES ${OpenCL_LIBRARIES} )
set( OPENCL_INCLUDE_DIRS ${OpenCL_INCLUDE_DIRS} )

# Find Boost on the system, and configure the type of boost build we want
set( Boost_USE_MULTITHREADED ON )
set( Boost_USE_STATIC_LIBS   ON )
set( Boost_DETAILED_FAILURE_MSG   ON )
# set( Boost_DEBUG ON )
set( Boost_ADDITIONAL_VERSIONS "1.44.0" "1.44" "1.47.0" "1.47" "1.60.0" "1.60" )

find_package( Boost 1.33.0 COMPONENTS program_options )
message(STATUS "Boost_PROGRAM_OPTIONS_LIBRARY: ${Boost_PROGRAM_OPTIONS_LIBRARY}")


if( NOT Boost_FOUND )
	message( STATUS "The clBLAS ktest requires boost to be installed" )
	set( BUILD_KTEST OFF )
	message( STATUS "The clBLAS client requires boost to be installed" )
	set( BUILD_CLIENT OFF )
endif()

# Turn on maximum compiler verbosity
if(CMAKE_COMPILER_IS_GNUCXX)
    add_definitions(# -pedantic -Wall -Wextra
        -D_POSIX_C_SOURCE=199309L -D_XOPEN_SOURCE=500
    )
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -Wstrict-prototypes" CACHE STRING
        "Default CFLAGS" FORCE)
    # Don't use -rpath.
    set(CMAKE_SKIP_RPATH ON CACHE BOOL "Skip RPATH" FORCE)

    # Need to determine the target machine of the C compiler, because
    # the '-m32' and '-m64' flags are supported on x86 but not on e.g. ARM.
    exec_program( "${CMAKE_C_COMPILER} -dumpmachine"
        OUTPUT_VARIABLE CMAKE_C_COMPILER_MACHINE )
    message( STATUS "CMAKE_C_COMPILER_MACHINE: ${CMAKE_C_COMPILER_MACHINE}" )
    # The "86" regular expression matches x86, x86_64, i686, etc.
    if(${CMAKE_C_COMPILER_MACHINE} MATCHES "86")
        set(CMAKE_C_FLAGS "-m${TARGET_PLATFORM} ${CMAKE_C_FLAGS}")
        set(CMAKE_CXX_FLAGS "-m${TARGET_PLATFORM} ${CMAKE_CXX_FLAGS}")
        set(CMAKE_Fortran_FLAGS "-m${TARGET_PLATFORM} ${CMAKE_Fortran_FLAGS}")
    endif()

    if(TARGET_PLATFORM EQUAL 32)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-builtin")
    endif()
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-narrowing")
elseif( MSVC )
	# CMake sets huge stack frames for windows, for whatever reason.  We go with compiler default.
	string( REGEX REPLACE "/STACK:[0-9]+" "" CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}" )
	string( REGEX REPLACE "/STACK:[0-9]+" "" CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}" )
	string( REGEX REPLACE "/STACK:[0-9]+" "" CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS}" )
endif( )

if (WIN32)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif( )

#TODO:  We should remove this pre-processor define for our 1.8 build; this means removing our deprecated image functions such as calls clCreateImage2D( )
add_definitions( -DCL_USE_DEPRECATED_OPENCL_1_1_APIS )

configure_file( "${PROJECT_SOURCE_DIR}/clBLAS.version.h.in" "${PROJECT_BINARY_DIR}/include/clBLAS.version.h" )

# configure a header file to pass the CMake version settings to the source, and package the header files in the output archive
install( FILES
			"clBLAS.h"
			"clAmdBlas.h"
			"clAmdBlas.version.h"
			"clBLAS-complex.h"
			"${PROJECT_BINARY_DIR}/include/clBLAS.version.h"
		DESTINATION
			"./include" )


if( BUILD_CLIENT AND IS_DIRECTORY "${PROJECT_SOURCE_DIR}/client")
	add_subdirectory( client )
endif( )

if( BUILD_PERFORMANCE AND IS_DIRECTORY "${PROJECT_SOURCE_DIR}/scripts/perf" )
	add_subdirectory( scripts/perf )
endif( )

if( BUILD_RUNTIME AND IS_DIRECTORY "${PROJECT_SOURCE_DIR}/library" )
#	add_subdirectory( library/tools/bingen )
	add_subdirectory( library )
	add_subdirectory( library/tools/tune )
	if( BUILD_KTEST )
		add_subdirectory( library/tools/ktest )
	endif( )
endif()

if( BUILD_SAMPLE AND IS_DIRECTORY "${PROJECT_SOURCE_DIR}/samples" )
	add_subdirectory( samples )
endif( )

# The build server is not supposed to build or package any of the tests; build server script will define this on the command line with
# cmake -G "Visual Studio 10 Win64" -D BUILDSERVER:BOOL=ON ../..
if( BUILD_TEST )
	if( IS_DIRECTORY "${PROJECT_SOURCE_DIR}/tests" )
		add_subdirectory(tests)
	endif( )

	# These tests #include <getopts.h>, which is not windows compliant
	if (NOT WIN32 AND IS_DIRECTORY "${PROJECT_SOURCE_DIR}/library" )
		add_subdirectory( library/blas/gens/tests )
		add_subdirectory( library/blas/gens/legacy/tests )
		add_subdirectory( library/common/tests )
	endif( )
endif( )

if(WIN32)
  set(destdir CMake)
else()
  set(destdir lib${SUFFIX_LIB}/cmake/clBLAS)
endif()
string(REGEX REPLACE "[^/]+" ".." reldir "${destdir}")
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/clBLASConfigVersion.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/clBLASConfigVersion.cmake
  @ONLY)
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/clBLASConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/clBLASConfig.cmake
  @ONLY)
install(EXPORT Library DESTINATION ${destdir} FILE clBLASTargets.cmake)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/clBLASConfigVersion.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/clBLASConfig.cmake
  DESTINATION ${destdir})


# The following code is setting variables to control the behavior of CPack to generate our
if( WIN32 )
	set( CPACK_SOURCE_GENERATOR "ZIP" )
	set( CPACK_GENERATOR "ZIP" )
else( )
	set( CPACK_SOURCE_GENERATOR "TGZ" )
	set( CPACK_GENERATOR "TGZ" )
endif( )

if( TARGET_PLATFORM EQUAL 64 )
	set( CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${clBLAS_VERSION}-${CMAKE_HOST_SYSTEM_NAME}-x64")
else( )
	set( CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${clBLAS_VERSION}-${CMAKE_HOST_SYSTEM_NAME}-x32")
endif( )

set( CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${clBLAS_VERSION}-${CMAKE_HOST_SYSTEM_NAME}-Source")

set( CPACK_PACKAGE_VERSION_MAJOR ${clBLAS_VERSION_MAJOR} )
set( CPACK_PACKAGE_VERSION_MINOR ${clBLAS_VERSION_MINOR} )
set( CPACK_PACKAGE_VERSION_PATCH ${clBLAS_VERSION_PATCH} )
set( CPACK_PACKAGE_DESCRIPTION_SUMMARY "OpenCL implementation of a BLAS library")
set( CPACK_PACKAGE_VENDOR "Neutral")
set( CPACK_SOURCE_IGNORE_FILES "/\\\\.hg/;/\\\\.svn/;/\\\\.git/" )

# Define all variables that influence CPack before including CPack, such as install targets
include( CPack )
