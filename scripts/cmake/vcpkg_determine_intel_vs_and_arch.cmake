## # vcpkg_determine_intel_vs_and_arch
##
## Determines the Visual Studio instance and Architecture required by the intel batch files
##
## ## Usage
## ```cmake
## vcpkg_determine_intel_vs_and_arch(intel_vs_out intel_arch_out)
## ```
##
## ## Parameters (Output Only)
## ### <positional>
## 1. Intel VS toolset
## 2. Intel architecture
##
function(vcpkg_determine_intel_vs_and_arch _intel_vs_out _intel_arch_out)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITECTURE})
    endif()

    if("$ENV{HOST_ARCHITECTURE}-${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x86-x86")
        set(${_intel_arch_out} "ia32")
    elseif("${HOST_ARCHITECTURE}-${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x86-x64")
        set(${_intel_arch_out} "ia32_intel64")
    elseif("${HOST_ARCHITECTURE}-${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "AMD64-x64")
        set(${_intel_arch_out} "intel64")
    else()
        message(FATAL_ERROR "Combination of host and target architecture is not supported by Intel")
    endif()

    if("${VCPKG_PLATFORM_TOOLSET}" STREQUAL "v140")
        set(${_intel_vs_out} "vs2015")
    elseif("${VCPKG_PLATFORM_TOOLSET}" STREQUAL "v141")
        set(${_intel_vs_out} "vs2017")
        # The Intel compilervars.bat expects the environment variable VS2017INSTALLDIR to be present so we set it
        if(NOT "$ENV{VS2017INSTALLDIR}")
            set(ENV{VS2017INSTALLDIR} "$ENV{VSINSTALLDIR}")
        endif()
    elseif("${VCPKG_PLATFORM_TOOLSET}" STREQUAL "v142")
        set(${_intel_vs_out} "vs2019")
        # The Intel compilervars.bat expects the environment variable VS2019INSTALLDIR to be present so we set it
        if(NOT "$ENV{VS2019INSTALLDIR}")
            set(ENV{VS2019INSTALLDIR} "$ENV{VSINSTALLDIR}")
        endif()
    else()
        message(FATAL_ERROR "Visual Studio version is not supported by Intel")
    endif()

    set(${_intel_vs_out} ${${_intel_vs_out}} PARENT_SCOPE)
    set(${_intel_arch_out} ${${_intel_arch_out}} PARENT_SCOPE)
endfunction()