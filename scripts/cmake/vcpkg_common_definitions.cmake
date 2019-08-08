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

#Helper variable to identify the host path seperator. 
if(CMAKE_HOST_WIN32)
    set(VCPKG_HOST_PATH_SEPARATOR ";")
    set(VCPKG_HOST_PATH_SEPARATOR_ESCAPED "\\;") #sometimes needed to differentiate between the cmake list separator
elseif(CMAKE_HOST_UNIX)
    set(VCPKG_HOST_PATH_SEPARATOR ":")
    set(VCPKG_HOST_PATH_SEPARATOR_ESCAPED ":")
endif()