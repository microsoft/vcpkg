## # vcpkg_common_definitions
##
## File contains helpful variabls for portfiles which are commonly needed or used.
##
## ## The following variables are available:
## ```cmake
## VCPKG_TARGET_IS_<target>                 with <target> being one of the following: WINDOWS, UWP, LINUX, OSX, ANDROID, FREEBSD. only defined if <target>
## VCPKG_HOST_EXECUTABLE_SUFFIX             executable suffix of the host
## VCPKG_TARGET_EXECUTABLE_SUFFIX           executable suffix of the target
## VCPKG_TARGET_STATIC_LIBRARY_PREFIX       static library prefix for target (same as CMAKE_STATIC_LIBRARY_PREFIX)
## VCPKG_TARGET_STATIC_LIBRARY_SUFFIX       static library suffix for target (same as CMAKE_STATIC_LIBRARY_SUFFIX)
## VCPKG_TARGET_SHARED_LIBRARY_PREFIX       shared library prefix for target (same as CMAKE_SHARED_LIBRARY_PREFIX)
## VCPKG_TARGET_SHARED_LIBRARY_SUFFIX       shared library suffix for target (same as CMAKE_SHARED_LIBRARY_SUFFIX)
## ```
## 
## CMAKE_STATIC_LIBRARY_PREFIX, CMAKE_STATIC_LIBRARY_SUFFIX, CMAKE_SHARED_LIBRARY_PREFIX, CMAKE_SHARED_LIBRARY_SUFFIX are defined for the target so that 
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
if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_TARGET_STATIC_LIBRARY_SUFFIX ".lib")
    set(VCPKG_TARGET_SHARED_LIBRARY_SUFFIX ".dll")
    set(VCPKG_TARGET_STATIC_LIBRARY_PREFIX "")
    set(VCPKG_TARGET_SHARED_LIBRARY_PREFIX "")
else()
    set(VCPKG_TARGET_STATIC_LIBRARY_SUFFIX ".a")
    set(VCPKG_TARGET_SHARED_LIBRARY_SUFFIX ".so")
    set(VCPKG_TARGET_STATIC_LIBRARY_PREFIX "lib")
    set(VCPKG_TARGET_SHARED_LIBRARY_PREFIX "lib")
endif()
#Setting these variables allows find_library to work in script mode and thus in portfiles!
#This allows us scale down on hardcoded target dependent paths in portfiles
set(CMAKE_STATIC_LIBRARY_SUFFIX ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
set(CMAKE_SHARED_LIBRARY_SUFFIX ${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX})
set(CMAKE_STATIC_LIBRARY_PREFIX ${VCPKG_TARGET_STATIC_LIBRARY_PREFIX})
set(CMAKE_SHARED_LIBRARY_PREFIX ${VCPKG_TARGET_SHARED_LIBRARY_PREFIX})
set(CMAKE_FIND_LIBRARY_SUFFIXES "${CMAKE_STATIC_LIBRARY_SUFFIX};${CMAKE_SHARED_LIBRARY_SUFFIX}" CACHE INTERNAL "") # Required by find_library
set(CMAKE_FIND_LIBRARY_PREFIXES "${CMAKE_STATIC_LIBRARY_PREFIX};${CMAKE_SHARED_LIBRARY_PREFIX}" CACHE INTERNAL "") # Required by find_library

