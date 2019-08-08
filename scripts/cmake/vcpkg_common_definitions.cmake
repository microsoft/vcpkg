## # vcpkg_common_definitions
##
## File contains helpful variabls for portfiles which are commonly needed or used.
##
## ## The following variables are available:
## ```cmake
## VCPKG_TARGET_IS_<target>                 with <target> being one of the following: WINDOWS, UWP, LINUX, OSX, ANDROID, FREEBSD. only defined if <target>
## VCPKG_HOST_EXECUTABLE_SUFFIX             executable suffix of the host
## VCPKG_TARGET_EXECUTABLE_SUFFIX           executable suffix of the target
## ```
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

