set(VCToolkit_VERSION "14.41.34120")
set(VCToolkit_REDIST_VERSION "14.40.33807")

set(${CMAKE_FIND_PACKAGE_NAME}_PACKAGE_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")

set(VCToolkit_DIR "${${CMAKE_FIND_PACKAGE_NAME}_PACKAGE_ROOT}/VS/VC/Tools/MSVC/${VCToolkit_VERSION}")

if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86")
    set(msvc_target_arch "x86")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^[Aa][Mm][Dd]64$")
    set(msvc_target_arch "x64")
else()
    message(FATAL_ERROR "Unsupported system processor: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^[Aa][Mm][Dd]64$")
    set(msvc_host_arch "x64")
else()
    message(FATAL_ERROR "Unsupported host system processor: ${CMAKE_HOST_SYSTEM_PROCESSOR}")
endif()

list(APPEND CMAKE_PROGRAM_PATH "${VCToolkit_DIR}/bin/Host${msvc_host_arch}/${msvc_target_arch}")

set(msvc_include_dirs "${VCToolkit_DIR}/include")
if(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    include_directories(SYSTEM ${msvc_include_dirs})
endif()
list(APPEND CMAKE_SYSTEM_INCLUDE_PATH ${msvc_include_dirs})
unset(msvc_include_dirs)

set(msvc_lib_dirs "${VCToolkit_DIR}/lib/${msvc_target_arch}")
if(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    link_directories(${msvc_lib_dirs})
endif()
list(APPEND CMAKE_SYSTEM_LIBRARY_PATH ${msvc_lib_dirs})
unset(msvc_lib_dirs)

find_program(CL_EXECUTABLE NAMES cl PATHS "${VCToolkit_DIR}/bin/Host${msvc_host_arch}/${msvc_target_arch}" REQUIRED NO_DEFAULT_PATH NO_CACHE)

# Cache variable used by InstallRequiredSystemLibraries
set(MSVC_REDIST_DIR "${${CMAKE_FIND_PACKAGE_NAME}_PACKAGE_ROOT}/VC/Redist/MSVC/${VCToolkit_REDIST_VERSION}" CACHE INTERNAL "" FORCE)

unset(MS_VC_Toolkit_DIR)
unset(msvc_host_arch)
unset(msvc_target_arch)

set(vctoolkit_FOUND TRUE)
set(VCToolkit_FOUND TRUE)