if(NOT _VCPKG_WINDOWS_TOOLCHAIN)
    set(_VCPKG_WINDOWS_TOOLCHAIN 1)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:${VCPKG_CRT_LINKAGE},dynamic>:DLL>" CACHE STRING "")
    set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "")

    if(POLICY CMP0056)
        cmake_policy(SET CMP0056 NEW)
    endif()
    if(POLICY CMP0066)
        cmake_policy(SET CMP0066 NEW)
    endif()
    if(POLICY CMP0067)
        cmake_policy(SET CMP0067 NEW)
    endif()
    if(POLICY CMP0137)
        cmake_policy(SET CMP0137 NEW)
    endif()
    list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
        VCPKG_CRT_LINKAGE VCPKG_TARGET_ARCHITECTURE VCPKG_SET_CHARSET_FLAG
        VCPKG_C_FLAGS VCPKG_CXX_FLAGS
        VCPKG_C_FLAGS_DEBUG VCPKG_CXX_FLAGS_DEBUG
        VCPKG_C_FLAGS_RELEASE VCPKG_CXX_FLAGS_RELEASE
        VCPKG_LINKER_FLAGS VCPKG_LINKER_FLAGS_RELEASE VCPKG_LINKER_FLAGS_DEBUG
        VCPKG_PLATFORM_TOOLSET
    )

    set(CMAKE_SYSTEM_NAME WindowsStore CACHE STRING "")

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(CMAKE_SYSTEM_PROCESSOR x86 CACHE STRING "")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING "")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(CMAKE_SYSTEM_PROCESSOR ARM CACHE STRING "")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(CMAKE_SYSTEM_PROCESSOR ARM64 CACHE STRING "")
    endif()

    if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
        set(CMAKE_SYSTEM_VERSION "${VCPKG_CMAKE_SYSTEM_VERSION}" CACHE STRING "" FORCE)
    endif()

    set(CMAKE_CROSSCOMPILING ON CACHE STRING "")

    if(NOT DEFINED CMAKE_SYSTEM_VERSION)
        set(CMAKE_SYSTEM_VERSION "${CMAKE_HOST_SYSTEM_VERSION}" CACHE STRING "")
    endif()

    if(NOT (DEFINED VCPKG_MSVC_CXX_WINRT_EXTENSIONS))
        set(VCPKG_MSVC_CXX_WINRT_EXTENSIONS ON)
    endif()

    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(VCPKG_CRT_LINK_FLAG_PREFIX "/MD")
    elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(VCPKG_CRT_LINK_FLAG_PREFIX "/MT")
    else()
        message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\". It must be \"static\" or \"dynamic\"")
    endif()

    set(CHARSET_FLAG "/utf-8")
    if (NOT VCPKG_SET_CHARSET_FLAG OR VCPKG_PLATFORM_TOOLSET MATCHES "v120")
        # VS 2013 does not support /utf-8
        set(CHARSET_FLAG "")
    endif()

    set(MP_BUILD_FLAG "")
    if(NOT (CMAKE_CXX_COMPILER MATCHES "clang-cl.exe"))
        set(MP_BUILD_FLAG "/MP ")
    endif()

    set(_vcpkg_cpp_flags "/DWIN32 /D_WINDOWS /D_UNICODE /DUNICODE /DWINAPI_FAMILY=WINAPI_FAMILY_APP /D__WRL_NO_DEFAULT_LIB__" ) # VS adds /D "_WINDLL" for DLLs;
    set(_vcpkg_common_flags "/nologo /Z7 ${MP_BUILD_FLAG}/GS /Gd /Gm- /W3 /WX- /Zc:wchar_t /Zc:inline /Zc:forScope /fp:precise /Oy- /EHsc")
    #/ZW:nostdlib -> ZW is added by CMake # VS also normally adds /sdl but not cmake MSBUILD
    set(_vcpkg_winmd_flag "")
    if(VCPKG_MSVC_CXX_WINRT_EXTENSIONS)
        file(TO_CMAKE_PATH "$ENV{VCToolsInstallDir}" _vcpkg_vctools)
        set(ENV{_CL_} "/FU\"${_vcpkg_vctools}/lib/x86/store/references/platform.winmd\" $ENV{_CL_}")
        # CMake has problems to correctly pass this in the compiler test so probably need special care in get_cmake_vars
        #set(_vcpkg_winmd_flag "/FU\\\\\"${_vcpkg_vctools}/lib/x86/store/references/platform.winmd\\\\\"") # VS normally passes /ZW for Apps
    endif()

    set(CMAKE_CXX_FLAGS "${_vcpkg_cpp_flags} ${_vcpkg_common_flags} ${_vcpkg_winmd_flag} ${CHARSET_FLAG} ${VCPKG_CXX_FLAGS}" CACHE STRING "")
    set(CMAKE_C_FLAGS "${_vcpkg_cpp_flags} ${_vcpkg_common_flags} ${_vcpkg_winmd_flag} ${CHARSET_FLAG} ${VCPKG_C_FLAGS}" CACHE STRING "")
    set(CMAKE_RC_FLAGS "-c65001 ${_vcpkg_cpp_flags}" CACHE STRING "")

    unset(CHARSET_FLAG)
    unset(MP_BUILD_FLAG)
    unset(_vcpkg_cpp_flags)
    unset(_vcpkg_common_flags)
    unset(_vcpkg_winmd_flag)

    set(CMAKE_CXX_FLAGS_DEBUG "${VCPKG_CRT_LINK_FLAG_PREFIX}d /Od /RTC1 ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")
    set(CMAKE_C_FLAGS_DEBUG "${VCPKG_CRT_LINK_FLAG_PREFIX}d /Od /RTC1 ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "")

    set(CMAKE_CXX_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG ${VCPKG_CXX_FLAGS_RELEASE}" CACHE STRING "") # VS adds /GL
    set(CMAKE_C_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "")

    string(APPEND CMAKE_STATIC_LINKER_FLAGS_RELEASE_INIT " /nologo ") # VS adds /LTCG

    if(VCPKG_MSVC_CXX_WINRT_EXTENSIONS)
        set(additional_dll_flags "/WINMD:NO ")
        if(CMAKE_GENERATOR MATCHES "Ninja")
            set(additional_exe_flags "/WINMD ") # VS Generator chokes on this in the compiler detection
        endif()
    endif()
    string(APPEND CMAKE_MODULE_LINKER_FLAGS " /MANIFEST:NO /NXCOMPAT /DYNAMICBASE /DEBUG ${additional_dll_flags}/APPCONTAINER /SUBSYSTEM:CONSOLE /MANIFESTUAC:NO ${VCPKG_LINKER_FLAGS}")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS " /MANIFEST:NO /NXCOMPAT /DYNAMICBASE /DEBUG ${additional_dll_flags}/APPCONTAINER /SUBSYSTEM:CONSOLE /MANIFESTUAC:NO ${VCPKG_LINKER_FLAGS}")
    # VS adds /DEBUG:FULL /TLBID:1.    WindowsApp.lib is in CMAKE_C|CXX_STANDARD_LIBRARIES
    string(APPEND CMAKE_EXE_LINKER_FLAGS " /MANIFEST:NO /NXCOMPAT /DYNAMICBASE /DEBUG ${additional_exe_flags}/APPCONTAINER /MANIFESTUAC:NO ${VCPKG_LINKER_FLAGS}")

    set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "") # VS uses /LTCG:incremental
    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "") # VS uses /LTCG:incremental
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")
    string(APPEND CMAKE_STATIC_LINKER_FLAGS_DEBUG_INIT " /nologo ")
    string(APPEND CMAKE_MODULE_LINKER_FLAGS_DEBUG_INIT " /nologo ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " /nologo ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " /nologo ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_DEBUG} ")
endif()
