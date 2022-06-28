#Toolset-Name: Intel C++ Compiler 2021
#C:\Program Files (x86)\Intel\oneAPI>setvars.bat
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_CRT_LINKAGE dynamic)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/x64-windows-ifort.toolchain.cmake")

if(NOT PORT MATCHES "(lapack)")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

#set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)
#set(VCPKG_POLICY_SKIP_DUMPBIN_CHECKS enabled)
set(VCPKG_LOAD_VCVARS_ENV ON)

include(vcpkg_load_environment_from_batch OPTIONAL RESULT_VARIABLE ENV_LOADABLE) # Trick to skip the internal compiler detection for this file. 
if(ENV_LOADABLE)
    if (DEFINED ENV{ProgramW6432})
        file(TO_CMAKE_PATH "$ENV{ProgramW6432}" PROG_ROOT)
    else()
        file(TO_CMAKE_PATH "$ENV{PROGRAMFILES}" PROG_ROOT)
    endif()
    if(NOT PROG_ROOT MATCHES "(x86)")
        set(PROG_ROOT "${PROG_ROOT} (x86)")
    endif()
    vcpkg_load_environment_from_batch(BATCH_FILE_PATH "${PROG_ROOT}/Intel/OneAPI/setvars.bat")
endif()