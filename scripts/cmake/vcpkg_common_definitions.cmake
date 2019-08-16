## # vcpkg_common_definitions
##
## File contains helpful variabls for portfiles which are commonly needed or used.
##
## ## The following variables are available:
## ```cmake
## VCPKG_TARGET_IS_<target>                 with <target> being one of the following: WINDOWS, UWP, LINUX, OSX, ANDROID, FREEBSD. only defined if <target>
## VCPKG_BUILD_LIST                         List of VCPKG_BUILD_TYPE which the current port will build (uppercase)
## VCPKG_BUILD_SHORT_NAME_<BUILDTYPE>       Short name of the buildtype (e.g. DEBUG=dbg; RELEASE=rel)
## VCPKG_PATH_SUFFIX_<BUILDTYPE>            Path suffix used for the buildtype (e.g. /debug)
## VCPKG_BUILDTREE_TRIPLET_DIR_<BUILDTYPE>  Path to current buildtype buildtree (e.g. CURRENT_BUILDTREES_DIR/TRIPLET-rel )
## ```
## 

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(VCPKG_TARGET_IS_WINDOWS 1)
    if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(VCPKG_TARGET_IS_UWP 1)
    endif()
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(VCPKG_TARGET_IS_OSX 1)
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(VCPKG_TARGET_IS_LINUX 1)
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android")
    set(VCPKG_TARGET_IS_ANDROID 1)
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    set(VCPKG_TARGET_IS_FREEBSD 1)
endif()

# Script helpers for looping over the different buildtypes
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(_buildname "DEBUG")
    list(APPEND VCPKG_BUILD_LIST ${_buildname})
    set(VCPKG_BUILD_SHORT_NAME_${_buildname} "dbg")
    set(VCPKG_PATH_SUFFIX_${_buildname} "/debug")
    set(VCPKG_BUILDTREE_TRIPLET_DIR_${_buildname} "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${VCPKG_BUILD_SHORT_NAME_${_buildname}}")
    unset(_buildname)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(_buildname "RELEASE")
    list(APPEND VCPKG_BUILD_LIST ${_buildname})
    set(VCPKG_BUILD_SHORT_NAME_${_buildname} "rel")
    set(VCPKG_PATH_SUFFIX_${_buildname} "")
    set(VCPKG_BUILDTREE_TRIPLET_DIR_${_buildname} "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${VCPKG_BUILD_SHORT_NAME_${_buildname}}")
    unset(_buildname)
endif()