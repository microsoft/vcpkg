set(WinSDK_VERSION "10.0.26100.0")

set(${CMAKE_FIND_PACKAGE_NAME}_PACKAGE_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")
set(WinSDK_DIR "${${CMAKE_FIND_PACKAGE_NAME}_PACKAGE_ROOT}/WinSDK/Windows Kits/10")

include("${CMAKE_CURRENT_LIST_DIR}/winsdk-version-info.cmake")

set(win_include_dirs
    "${WinSDK_DIR}/Include/${WinSDK_VERSION}/um"     # windows.h 
    "${WinSDK_DIR}/Include/${WinSDK_VERSION}/ucrt"   # corecrt.h
    "${WinSDK_DIR}/Include/${WinSDK_VERSION}/shared" # ntverp.h
    "${WinSDK_DIR}/Include/${WinSDK_VERSION}/winrt"  # wrl.h
)
if(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    include_directories(SYSTEM ${win_include_dirs})
endif()
list(APPEND CMAKE_SYSTEM_INCLUDE_PATH ${win_include_dirs})
unset(win_include_dirs)

if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86")
    set(msvc_target_arch "x86")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^[Aa][Mm][Dd]64$")
    set(msvc_target_arch "x64")
else()
    message(FATAL_ERROR "Unsupported system processor: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

set(win_lib_dirs
    "${WinSDK_DIR}/Lib/${WinSDK_VERSION}/um/${msvc_target_arch}"   #kernel32.lib
    "${WinSDK_DIR}/Lib/${WinSDK_VERSION}/ucrt/${msvc_target_arch}" #ucrtd.lib
)
if(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    link_directories(${win_lib_dirs})
endif()
list(APPEND CMAKE_SYSTEM_LIBRARY_PATH ${win_lib_dirs})
unset(win_lib_dirs)

if(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    add_compile_options(/X)
endif()

set(ENV{CMAKE_WINDOWS_KITS_10_DIR} "${WinSDK_DIR}")
set(ENV{UCRTVersion} "${WinSDK_VERSION}")

set(CMAKE_SYSTEM_VERSION "${WinSDK_VERSION}")
set(CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION "${WinSDK_VERSION}")
list(APPEND CMAKE_PROGRAM_PATH "${WinSDK_DIR}/bin/$ENV{UCRTVersion}/${msvc_target_arch}")

find_program(SIGNTOOL_EXECUTABLE NAMES signtool PATHS "${WinSDK_DIR}/bin/$ENV{UCRTVersion}/${msvc_target_arch}" REQUIRED NO_DEFAULT_PATH NO_CACHE)

# Cache variable used by InstallRequiredSystemLibraries
set(WINDOWS_KITS_DIR "${WinSDK_DIR}" CACHE INTERNAL "" FORCE)

set(WinSDK_FOUND TRUE)
set(winsdk_FOUND TRUE)
set(WINSDK_FOUND TRUE)