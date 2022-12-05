#.rst:
# getopt-win32 config wrap for vcpkg
# ------------
#
# Find the getopt-win32 includes and library.
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This script defines the following variables:
#
# ``getopt-win32_FOUND``
#   True if getopt-win32 library found
#
# ``getopt-win32_INCLUDE_DIR``
#   Location of getopt-win32 headers
#
# ``getopt-win32_LIBRARY``
#   List of libraries to link with when using getopt-win32
#
# Result Targets
# ^^^^^^^^^^^^^^^^
#
# This script defines the following targets:
#
# ``getopt-win32``
#   Target to use getopt-win32
#

include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

if(NOT getopt-win32_INCLUDE_DIR)
    find_path(getopt-win32_INCLUDE_DIR NAMES getopt.h PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include" NO_DEFAULT_PATH)
endif()

if(NOT getopt-win32_LIBRARY)
    find_library(getopt-win32_LIBRARY_RELEASE NAMES getopt PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
    find_library(getopt-win32_LIBRARY_DEBUG NAMES getopt PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    select_library_configurations(getopt-win32)
endif()

find_package_handle_standard_args(getopt-win32 DEFAULT_MSG getopt-win32_LIBRARY getopt-win32_INCLUDE_DIR)
mark_as_advanced(getopt-win32_INCLUDE_DIR getopt-win32_LIBRARY)

get_filename_component(getopt-win32_DLL_DIR ${getopt-win32_INCLUDE_DIR}/../bin ABSOLUTE)
message(STATUS "getopt-win32_DLL_DIR: ${getopt-win32_DLL_DIR}")
get_filename_component(getopt-win32_DEBUG_DLL_DIR ${getopt-win32_INCLUDE_DIR}/../debug/bin ABSOLUTE)
message(STATUS "getopt-win32_DEBUG_DLL_DIR: ${getopt-win32_DEBUG_DLL_DIR}")

find_file(getopt-win32_LIBRARY_RELEASE_DLL NAMES getopt.dll PATHS ${getopt-win32_DLL_DIR})
find_file(getopt-win32_LIBRARY_DEBUG_DLL NAMES getopt.dll PATHS ${getopt-win32_DEBUG_DLL_DIR})

if(getopt-win32_FOUND AND NOT TARGET getopt-win32)
    if(EXISTS "${getopt-win32_LIBRARY_RELEASE_DLL}")
        add_library(getopt-win32 SHARED IMPORTED)
        set_target_properties(
            getopt-win32
            PROPERTIES
                IMPORTED_LOCATION_RELEASE         "${getopt-win32_LIBRARY_RELEASE_DLL}"
                IMPORTED_IMPLIB                   "${getopt-win32_LIBRARY_RELEASE}"
                INTERFACE_INCLUDE_DIRECTORIES     "${getopt-win32_INCLUDE_DIR}"
                IMPORTED_CONFIGURATIONS           Release
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        )

        if(EXISTS "${getopt-win32_LIBRARY_DEBUG_DLL}")
            set_property(TARGET getopt-win32 APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
            set_target_properties(
                getopt-win32
                PROPERTIES
                    IMPORTED_LOCATION_DEBUG "${getopt-win32_LIBRARY_DEBUG_DLL}"
                    IMPORTED_IMPLIB_DEBUG   "${getopt-win32_LIBRARY_DEBUG}"
            )
        endif()
    else()
        add_library(getopt-win32 UNKNOWN IMPORTED)
        set_target_properties(
            getopt-win32
            PROPERTIES
                IMPORTED_LOCATION_RELEASE         "${getopt-win32_LIBRARY_RELEASE}"
                INTERFACE_INCLUDE_DIRECTORIES     "${getopt-win32_INCLUDE_DIR}"
                IMPORTED_CONFIGURATIONS           Release
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        )

        if(EXISTS "${getopt-win32_LIBRARY_DEBUG}")
            set_property(TARGET getopt-win32 APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
            
            set_target_properties(
                getopt-win32
                PROPERTIES
                    IMPORTED_LOCATION_DEBUG "${getopt-win32_LIBRARY_DEBUG}"
            )
        endif()
    endif()
endif()
