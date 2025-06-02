# - Try to find duktape
# Once done this will define
#
#  DUKTAPE_FOUND - system has Duktape
#  DUKTAPE_INCLUDE_DIRS - the Duktape include directory
#  DUKTAPE_LIBRARIES - Link these to use DUKTAPE
#  DUKTAPE_DEFINITIONS - Compiler switches required for using Duktape
#

include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

find_path(DUKTAPE_INCLUDE_DIR duktape.h PATHS "${CMAKE_CURRENT_LIST_DIR}/../../include" NO_DEFAULT_PATH REQUIRED)

find_library(DUKTAPE_LIBRARY_RELEASE NAMES duktape PATHS "${CMAKE_CURRENT_LIST_DIR}/../../lib" NO_DEFAULT_PATH REQUIRED)
find_library(DUKTAPE_LIBRARY_DEBUG NAMES duktape PATHS "${CMAKE_CURRENT_LIST_DIR}/../../debug/lib" NO_DEFAULT_PATH)
select_library_configurations(DUKTAPE)

find_package_handle_standard_args(duktape
    REQUIRED_VARS DUKTAPE_LIBRARY DUKTAPE_INCLUDE_DIR)

if(DUKTAPE_FOUND)
    set(DUKTAPE_INCLUDE_DIRS "${DUKTAPE_INCLUDE_DIR}")
    set(DUKTAPE_LIBRARIES "${DUKTAPE_LIBRARY}")
    set(DUKTAPE_DEFINITIONS "")
endif ()

mark_as_advanced(
    DUKTAPE_INCLUDE_DIR
    DUKTAPE_LIBRARY_RELEASE
    DUKTAPE_LIBRARY_DEBUG
)
