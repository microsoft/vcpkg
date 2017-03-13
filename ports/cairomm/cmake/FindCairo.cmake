# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.
#
# revision: 2
# See https://github.com/CMakePorts/CMakeFindPackages for updates
#
#.rst:
# FindCairo
# ---------
#
# Locate Cairo library
#
# This module defines
#
# ::
#  CAIRO_FOUND          - system has the CAIRO library
#  CAIRO_INCLUDE_DIR    - the CAIRO include directory
#  CAIRO_LIBRARIES      - The libraries needed to use CAIRO
#  CAIRO_VERSION        - This is set to $major.$minor.$revision (eg. 0.9.8)
#  CAIRO_VERSION_STRING - This is set to $major.$minor.$revision (eg. 0.9.8)
#
# Authors:
#  Copyright (c)           Eric Wing
#  Copyright (c)           Alexander Neundorf
#  Copyright (c) 2008      Joshua L. Blocher  <verbalshadow at gmail dot com>
#  Copyright (c) 2012      Dmitry Baryshnikov <polimax at mail dot ru>
#  Copyright (c) 2013-2017 Mikhail Paulyshka  <me at mixaill dot tk>
#


if (NOT WIN32)
    find_package(PkgConfig)
    if (PKG_CONFIG_FOUND)
        pkg_check_modules(_CAIRO cairo)

        SET(CAIRO_VERSION ${_CAIRO_VERSION})
        STRING (REGEX REPLACE "([0-9]+).([0-9]+).([0-9]+)" "\\1" num "${CAIRO_VERSION}")
        MATH (EXPR CAIRO_VERSION_MAJOR "${num}")
        STRING (REGEX REPLACE "([0-9]+).([0-9]+).([0-9]+)" "\\2" num "${CAIRO_VERSION}")
        MATH (EXPR CAIRO_VERSION_MINOR "${num}")
        STRING (REGEX REPLACE "([0-9]+).([0-9]+).([0-9]+)" "\\3" num "${CAIRO_VERSION}")
        MATH (EXPR CAIRO_VERSION_MICRO "${num}")
    endif (PKG_CONFIG_FOUND)
endif (NOT WIN32)

set(_CAIRO_ROOT_HINTS_AND_PATHS
  HINTS
     $ENV{CAIRO}
     $ENV{CAIRO_DIR}
     ${CMAKE_FIND_ROOT_PATH}
     ${CAIRO_ROOT_DIR}
  PATHS
    ${CMAKE_FIND_ROOT_PATH}
    $ENV{CAIRO}/src
    /usr
    /usr/local
)

find_path(CAIRO_INCLUDE_DIR
    NAMES
        cairo.h
    HINTS
        ${_CAIRO_INCLUDEDIR}
        ${_CAIRO_ROOT_HINTS_AND_PATHS}
    PATH_SUFFIXES
        include
        "include/cairo"
)

if(NOT CAIRO_LIBRARY)
    FIND_LIBRARY(CAIRO_LIBRARY_RELEASE
        NAMES
            cairo
            cairo-static
        HINTS
            ${_CAIRO_LIBDIR}
            ${_CAIRO_ROOT_HINTS_AND_PATHS}
        PATH_SUFFIXES
            "lib"
            "local/lib"
    )

    FIND_LIBRARY(CAIRO_LIBRARY_DEBUG
        NAMES
            cairod
            cairo-staticd
        HINTS
            ${_CAIRO_LIBDIR}
            ${_CAIRO_ROOT_HINTS_AND_PATHS}
        PATH_SUFFIXES
            "lib"
            "local/lib"
    )

    include(SelectLibraryConfigurations)
    select_library_configurations(CAIRO)
endif()
set(CAIRO_LIBRARIES ${CAIRO_LIBRARY})

if (NOT CAIRO_VERSION)
    if (EXISTS "${CAIRO_INCLUDE_DIR}/cairo-version.h")
        file(READ "${CAIRO_INCLUDE_DIR}/cairo-version.h" CAIRO_VERSION_CONTENT)

        string(REGEX MATCH "#define +CAIRO_VERSION_MAJOR +([0-9]+)" _dummy "${CAIRO_VERSION_CONTENT}")
        set(CAIRO_VERSION_MAJOR "${CMAKE_MATCH_1}")

        string(REGEX MATCH "#define +CAIRO_VERSION_MINOR +([0-9]+)" _dummy "${CAIRO_VERSION_CONTENT}")
        set(CAIRO_VERSION_MINOR "${CMAKE_MATCH_1}")

        string(REGEX MATCH "#define +CAIRO_VERSION_MICRO +([0-9]+)" _dummy "${CAIRO_VERSION_CONTENT}")
        set(CAIRO_VERSION_MICRO "${CMAKE_MATCH_1}")

        set(CAIRO_VERSION "${CAIRO_VERSION_MAJOR}.${CAIRO_VERSION_MINOR}.${CAIRO_VERSION_MICRO}")
        set(CAIRO_VERSION_STRING CAIRO_VERSION)
    endif ()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    CAIRO
    REQUIRED_VARS
        CAIRO_LIBRARIES
        CAIRO_INCLUDE_DIR
    VERSION_VAR
        CAIRO_VERSION_STRING
)

MARK_AS_ADVANCED(
    CAIRO_INCLUDE_DIR
    CAIRO_LIBRARY
    CAIRO_LIBRARIES)
