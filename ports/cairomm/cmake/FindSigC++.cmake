# - Try to find SIGC++
# Once done this will define
#
#  SIGC++_ROOT_DIR - Set this variable to the root installation of SIGC++
#  SIGC++_FOUND - system has SIGC++
#  SIGC++_INCLUDE_DIRS - the SIGC++ include directory
#  SIGC++_LIBRARIES - Link these to use SIGC++
#
#  Copyright (c) 2008      Joshua L. Blocher  <verbalshadow at gmail dot com>
#  Copyright (c) 2012      Dmitry Baryshnikov <polimax at mail dot ru>
#  Copyright (c) 2013-2017 Mikhail Paulyshka  <me at mixaill dot tk>
#
#  Distributed under the OSI-approved BSD License
#

if (NOT WIN32)
    find_package(PkgConfig)
    if (PKG_CONFIG_FOUND)
        pkg_check_modules(_SIGC++ sigc++-2.0)
        SET(SIGC++_VERSION ${_SIGC++_VERSION})
    endif (PKG_CONFIG_FOUND)
endif (NOT WIN32)

SET(_SIGC++_ROOT_HINTS
    $ENV{SIGC++}
    ${CMAKE_FIND_ROOT_PATH}
    ${SIGC++_ROOT_DIR}
)

SET(_SIGC++_ROOT_PATHS
    $ENV{SIGC++}/src
    /usr
    /usr/local
)

SET(_SIGC++_ROOT_HINTS_AND_PATHS
    HINTS ${_SIGC++_ROOT_HINTS}
    PATHS ${_SIGC++_ROOT_PATHS}
)

FIND_PATH(SIGC++_INCLUDE_DIR
    NAMES
        "sigc++/sigc++.h"
    HINTS
        ${_SIGC++_INCLUDEDIR}
        ${_SIGC++_ROOT_HINTS_AND_PATHS}
    PATH_SUFFIXES
        include
        "include/sigc++-2.0"
)

find_path(SIGC++_CONFIG_INCLUDE_DIR
    NAMES
        sigc++config.h
    HINTS
        ${_SIGC++_LIBDIR}
        ${_SIGC++_INCLUDEDIR}
        ${_SIGC++_ROOT_HINTS_AND_PATHS}
    PATH_SUFFIXES
        include
        lib
        "sigc++-2.0/include"
        "lib/sigc++-2.0"
        "lib/sigc++-2.0/include"
)

FIND_LIBRARY(SIGC++_LIBRARY
    NAMES
        sigc-2.0
    HINTS
        ${_SIGC++_LIBDIR}
        ${_SIGC++_ROOT_HINTS_AND_PATHS}
    PATH_SUFFIXES
        "lib"
        "local/lib"
)

SET(SIGC++_LIBRARIES
    ${SIGC++_LIBRARY}
)

SET(SIGC++_INCLUDE_DIRS
    ${SIGC++_INCLUDE_DIR}
    ${SIGC++_CONFIG_INCLUDE_DIR}
)

if (NOT SIGC++_VERSION)
    if (EXISTS "${SIGC++_CONFIG_INCLUDE_DIR}/sigc++config.h")
        file(READ "${SIGC++_CONFIG_INCLUDE_DIR}/sigc++config.h" SIGC++_VERSION_CONTENT)

        string(REGEX MATCH "#define +SIGCXX_MAJOR_VERSION +([0-9]+)" _dummy "${SIGC++_VERSION_CONTENT}")
        set(SIGC++_VERSION_MAJOR "${CMAKE_MATCH_1}")

        string(REGEX MATCH "#define +SIGCXX_MINOR_VERSION +([0-9]+)" _dummy "${SIGC++_VERSION_CONTENT}")
        set(SIGC++_VERSION_MINOR "${CMAKE_MATCH_1}")

        string(REGEX MATCH "#define +SIGCXX_MICRO_VERSION +([0-9]+)" _dummy "${SIGC++_VERSION_CONTENT}")
        set(SIGC++_VERSION_MICRO "${CMAKE_MATCH_1}")

        set(SIGC++_VERSION "${SIGC++_VERSION_MAJOR}.${SIGC++_VERSION_MINOR}.${SIGC++_VERSION_MICRO}")
    endif (EXISTS "${SIGC++_CONFIG_INCLUDE_DIR}/sigc++config.h")
endif(NOT SIGC++_VERSION)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SIGC++
    REQUIRED_VARS SIGC++_LIBRARIES SIGC++_INCLUDE_DIRS
    VERSION_VAR SIGC++_VERSION
    FAIL_MESSAGE "Could NOT find SIGC++, try to set the path to SIGC++ root folder in the system variable SIGC++"
)

MARK_AS_ADVANCED(SIGC++_CONFIG_INCLUDE_DIR SIGC++_INCLUDE_DIR SIGC++_INCLUDE_DIRS SIGC++_LIBRARY SIGC++_LIBRARIES)
