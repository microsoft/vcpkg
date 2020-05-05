## # vcpkg_common_definitions
##
## File contains helpful variabls for portfiles which are commonly needed or used.
##
## ## The following variables are available:
## ```cmake
## VCPKG_TARGET_IS_<target>                 with <target> being one of the following: WINDOWS, UWP, LINUX, OSX, ANDROID, FREEBSD. only defined if <target>
## VCPKG_HOST_PATH_SEPARATOR                Host specific path separator (USAGE: "<something>${VCPKG_HOST_PATH_SEPARATOR}<something>"; only use and pass variables with VCPKG_HOST_PATH_SEPARATOR within "")
## VCPKG_HOST_EXECUTABLE_SUFFIX             executable suffix of the host
## VCPKG_TARGET_EXECUTABLE_SUFFIX           executable suffix of the target
## VCPKG_TARGET_STATIC_LIBRARY_PREFIX       static library prefix for target (same as CMAKE_STATIC_LIBRARY_PREFIX)
## VCPKG_TARGET_STATIC_LIBRARY_SUFFIX       static library suffix for target (same as CMAKE_STATIC_LIBRARY_SUFFIX)
## VCPKG_TARGET_SHARED_LIBRARY_PREFIX       shared library prefix for target (same as CMAKE_SHARED_LIBRARY_PREFIX)
## VCPKG_TARGET_SHARED_LIBRARY_SUFFIX       shared library suffix for target (same as CMAKE_SHARED_LIBRARY_SUFFIX)
## VCPKG_TARGET_IMPORT_LIBRARY_PREFIX       import library prefix for target (same as CMAKE_IMPORT_LIBRARY_PREFIX)
## VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX       import library suffix for target (same as CMAKE_IMPORT_LIBRARY_SUFFIX)
## VCPKG_FIND_LIBRARY_PREFIXES              target dependent prefixes used for find_library calls in portfiles
## VCPKG_FIND_LIBRARY_SUFFIXES              target dependent suffixes used for find_library calls in portfiles
## VCPKG_BUILD_LIST                         List of VCPKG_BUILD_TYPE which the current port will build (uppercase)
## VCPKG_BUILD_SHORT_NAME_<BUILDTYPE>       Short name of the buildtype (e.g. DEBUG=dbg; RELEASE=rel)
## VCPKG_BUILD_CMAKE_TYPE_<BUILDTYPE>       CMAKE_BUILD_TYPE used for buildtype
## VCPKG_BUILD_QMAKE_CONFIG_<BUILDTYPE>     Required QMAKE CONFIG flags for buildtype
## VCPKG_PATH_SUFFIX_<BUILDTYPE>            Path suffix used for buildtype (e.g. /debug)
## VCPKG_BUILD_TRIPLET_<BUILDTYPE>          Fullname of the buildtriplet e.g. ${TARGET_TRIPLET}-${VCPKG_BUILD_SHORT_NAME_<BUILDTYPE>}
## VCPKG_BUILDTREE_TRIPLET_DIR_<BUILDTYPE>  Path to current buildtype buildtree (e.g. CURRENT_BUILDTREES_DIR/TRIPLET-rel )
## ```
##
## CMAKE_STATIC_LIBRARY_(PREFIX|SUFFIX), CMAKE_SHARED_LIBRARY_(PREFIX|SUFFIX) and CMAKE_IMPORT_LIBRARY_(PREFIX|SUFFIX) are defined for the target
## Furthermore the variables CMAKE_FIND_LIBRARY_(PREFIXES|SUFFIXES) are also defined for the target so that
## portfiles are able to use find_library calls to discover dependent libraries within the current triplet for ports.
##

#Helper variable to identify the Target system. VCPKG_TARGET_IS_<targetname>
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
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MinGW")
    set(VCPKG_TARGET_IS_WINDOWS 1)
    set(VCPKG_TARGET_IS_MINGW 1)
endif()

#Helper variable to identify the host path separator.
if(CMAKE_HOST_WIN32)
    set(VCPKG_HOST_PATH_SEPARATOR ";")
elseif(CMAKE_HOST_UNIX)
    set(VCPKG_HOST_PATH_SEPARATOR ":")
endif()

#Helper variables to identify executables on host/target
if(CMAKE_HOST_WIN32)
    set(VCPKG_HOST_EXECUTABLE_SUFFIX ".exe")
else()
    set(VCPKG_HOST_EXECUTABLE_SUFFIX "")
endif()
#set(CMAKE_EXECUTABLE_SUFFIX ${VCPKG_HOST_EXECUTABLE_SUFFIX}) not required by find_program

if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_TARGET_EXECUTABLE_SUFFIX ".exe")
else()
    set(VCPKG_TARGET_EXECUTABLE_SUFFIX "")
endif()

#Helper variables for libraries
if(VCPKG_TARGET_IS_MINGW)
    set(VCPKG_TARGET_STATIC_LIBRARY_SUFFIX ".a")
    set(VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX ".dll.a")
    set(VCPKG_TARGET_SHARED_LIBRARY_SUFFIX ".dll")
    set(VCPKG_TARGET_STATIC_LIBRARY_PREFIX "lib")
    set(VCPKG_TARGET_SHARED_LIBRARY_PREFIX "lib")
    set(VCPKG_TARGET_IMPORT_LIBRARY_PREFIX "lib")
    set(VCPKG_FIND_LIBRARY_SUFFIXES ".dll" ".dll.a" ".a" ".lib")
    set(VCPKG_FIND_LIBRARY_PREFIXES "lib" "")
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_TARGET_STATIC_LIBRARY_SUFFIX ".lib")
    set(VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX ".lib")
    set(VCPKG_TARGET_SHARED_LIBRARY_SUFFIX ".dll")
    set(VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX ".lib")
    set(VCPKG_TARGET_STATIC_LIBRARY_PREFIX "")
    set(VCPKG_TARGET_SHARED_LIBRARY_PREFIX "")
    set(VCPKG_TARGET_IMPORT_LIBRARY_PREFIX "")
    set(VCPKG_FIND_LIBRARY_SUFFIXES ".lib" ".dll") #This is a slight modification to CMakes value which does not include ".dll".
    set(VCPKG_FIND_LIBRARY_PREFIXES "" "lib") #This is a slight modification to CMakes value which does not include "lib".
elseif(VCPKG_TARGET_IS_OSX)
    set(VCPKG_TARGET_STATIC_LIBRARY_SUFFIX ".a")
    set(VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX "")
    set(VCPKG_TARGET_SHARED_LIBRARY_SUFFIX ".dylib")
    set(VCPKG_TARGET_STATIC_LIBRARY_PREFIX "lib")
    set(VCPKG_TARGET_SHARED_LIBRARY_PREFIX "lib")
    set(VCPKG_FIND_LIBRARY_SUFFIXES ".tbd" ".dylib" ".so" ".a")
    set(VCPKG_FIND_LIBRARY_PREFIXES "lib" "")
else()
    set(VCPKG_TARGET_STATIC_LIBRARY_SUFFIX ".a")
    set(VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX "")
    set(VCPKG_TARGET_SHARED_LIBRARY_SUFFIX ".so")
    set(VCPKG_TARGET_STATIC_LIBRARY_PREFIX "lib")
    set(VCPKG_TARGET_SHARED_LIBRARY_PREFIX "lib")
    set(VCPKG_FIND_LIBRARY_SUFFIXES ".so" ".a")
    set(VCPKG_FIND_LIBRARY_PREFIXES "lib" "")
endif()
#Setting these variables allows find_library to work in script mode and thus in portfiles!
#This allows us scale down on hardcoded target dependent paths in portfiles
set(CMAKE_STATIC_LIBRARY_SUFFIX "${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
set(CMAKE_SHARED_LIBRARY_SUFFIX "${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
set(CMAKE_IMPORT_LIBRARY_SUFFIX "${VCPKG_TARGET_IMPORT_LIBRARY_PREFIX}")
set(CMAKE_STATIC_LIBRARY_PREFIX "${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}")
set(CMAKE_SHARED_LIBRARY_PREFIX "${VCPKG_TARGET_SHARED_LIBRARY_PREFIX}")
set(CMAKE_IMPORT_LIBRARY_PREFIX "${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}")

set(CMAKE_FIND_LIBRARY_SUFFIXES "${VCPKG_FIND_LIBRARY_SUFFIXES}" CACHE INTERNAL "") # Required by find_library
set(CMAKE_FIND_LIBRARY_PREFIXES "${VCPKG_FIND_LIBRARY_PREFIXES}" CACHE INTERNAL "") # Required by find_library

# Script helpers for looping over the different buildtypes
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(_buildname "RELEASE")
    list(APPEND VCPKG_BUILD_LIST ${_buildname})
    #Might also be needed: set(VCPKG_BUILD_OPTION_MAPPING_${_buildname} "RELEASE") currently the value of VCPKG_BUILD_LIST is used 
    set(VCPKG_BUILD_SHORT_NAME_${_buildname} "rel")
    set(VCPKG_BUILD_CMAKE_TYPE_${_buildname} "Release")
    set(VCPKG_BUILD_QMAKE_CONFIG_${_buildname} "CONFIG+=release;CONFIG-=debug")
    set(VCPKG_PATH_SUFFIX_${_buildname} "")
    set(VCPKG_COPY_EXE_${_buildname} 1)
    set(VCPKG_BUILD_TRIPLET_${_buildname} "${TARGET_TRIPLET}-${VCPKG_BUILD_SHORT_NAME_${_buildname}}")
    set(VCPKG_BUILDTREE_TRIPLET_DIR_${_buildname} "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${VCPKG_BUILD_SHORT_NAME_${_buildname}}")
    unset(_buildname)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(_buildname "DEBUG")
    list(APPEND VCPKG_BUILD_LIST ${_buildname})
    #Might also be needed: set(VCPKG_BUILD_OPTION_MAPPING_${_buildname} "DEBUG") currently the value of VCPKG_BUILD_LIST is used 
    set(VCPKG_BUILD_SHORT_NAME_${_buildname} "dbg")
    set(VCPKG_BUILD_CMAKE_TYPE_${_buildname} "Debug")
    set(VCPKG_BUILD_QMAKE_CONFIG_${_buildname} "CONFIG-=release;CONFIG+=debug")
    set(VCPKG_PATH_SUFFIX_${_buildname} "/debug")
    set(VCPKG_BUILD_TRIPLET_${_buildname} "${TARGET_TRIPLET}-${VCPKG_BUILD_SHORT_NAME_${_buildname}}")
    set(VCPKG_BUILDTREE_TRIPLET_DIR_${_buildname} "${CURRENT_BUILDTREES_DIR}/${VCPKG_BUILD_TRIPLET_${_buildname}}")
    unset(_buildname)
endif()

