# - Try to find duktape
# Once done this will define
#
#  DUKTAPE_FOUND - system has Duktape
#  DUKTAPE_INCLUDE_DIRS - the Duktape include directory
#  DUKTAPE_LIBRARIES - Link these to use DUKTAPE
#  DUKTAPE_DEFINITIONS - Compiler switches required for using Duktape
#

find_package(PkgConfig QUIET)
pkg_check_modules(PC_DUK QUIET duktape libduktape)

find_path(DUKTAPE_INCLUDE_DIR duktape.h
    HINTS ${PC_DUK_INCLUDEDIR} ${PC_DUK_INCLUDE_DIRS}
    PATH_SUFFIXES duktape)

find_library(DUKTAPE_LIBRARY
    NAMES duktape libduktape
    HINTS ${PC_DUK_LIBDIR} ${PC_DUK_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Duktape
    REQUIRED_VARS DUKTAPE_LIBRARY DUKTAPE_INCLUDE_DIR)

if (DUKTAPE_FOUND)
    set (DUKTAPE_LIBRARIES ${DUKTAPE_LIBRARY})
    set (DUKTAPE_INCLUDE_DIRS ${DUKTAPE_INCLUDE_DIR} )
endif ()

MARK_AS_ADVANCED(
    DUKTAPE_INCLUDE_DIR
    DUKTAPE_LIBRARY
)