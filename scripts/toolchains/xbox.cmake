if(NOT _VCPKG_WINDOWS_TOOLCHAIN)
set(_VCPKG_WINDOWS_TOOLCHAIN 1)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:${VCPKG_CRT_LINKAGE},dynamic>:DLL>" CACHE STRING "")

set(CMAKE_SYSTEM_NAME Windows CACHE STRING "")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING "")
else()
    message(FATAL_ERROR "Xbox requires x64 native target.")
endif()

if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
    set(CMAKE_SYSTEM_VERSION "${VCPKG_CMAKE_SYSTEM_VERSION}" CACHE STRING "" FORCE)
endif()

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(CMAKE_CROSSCOMPILING ON CACHE STRING "")

    if(NOT DEFINED CMAKE_SYSTEM_VERSION)
        set(CMAKE_SYSTEM_VERSION "${CMAKE_HOST_SYSTEM_VERSION}" CACHE STRING "")
    endif()
endif()

get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
if(NOT _CMAKE_IN_TRY_COMPILE)

    set(_vcpkg_core_libs onecore_apiset.lib)

    set(CMAKE_C_STANDARD_LIBRARIES_INIT "${_vcpkg_core_libs}" CACHE STRING "" FORCE)
    set(CMAKE_CXX_STANDARD_LIBRARIES_INIT "${_vcpkg_core_libs}" CACHE STRING "" FORCE)

    set(CMAKE_C_STANDARD_LIBRARIES ${CMAKE_C_STANDARD_LIBRARIES_INIT} CACHE STRING "" FORCE)
    set(CMAKE_CXX_STANDARD_LIBRARIES ${CMAKE_CXX_STANDARD_LIBRARIES_INIT} CACHE STRING "" FORCE)

    unset(_vcpkg_core_libs)

    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(VCPKG_CRT_LINK_FLAG_PREFIX "/MD")
    elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(VCPKG_CRT_LINK_FLAG_PREFIX "/MT")
    else()
        message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\". It must be \"static\" or \"dynamic\"")
    endif()

    if (DEFINED ENV{GameDKLatest})
        if(XBOX_CONSOLE_TARGET STREQUAL "scarlett")
            set(_vcpkg_incpaths "/I\"$ENV{GameDKLatest}/GXDK/gameKit/Include\" /I\"$ENV{GameDKLatest}/GXDK/gameKit/Include/Scarlett\"")
        elseif(XBOX_CONSOLE_TARGET STREQUAL "xboxone")
            set(_vcpkg_incpaths "/I\"$ENV{GameDKLatest}/GXDK/gameKit/Include\" /I\"$ENV{GameDKLatest}/GXDK/gameKit/Include/XboxOne\"")
        endif()

        string(APPEND _vcpkg_incpaths " /I\"$ENV{GameDKLatest}/GRDK/gameKit/Include\"")
    endif()

    set(_vcpkg_cpp_flags "/DWIN32 /D_WINDOWS /D_UNICODE /DUNICODE /DWIN32_LEAN_AND_MEAN /DWINAPI_FAMILY=WINAPI_FAMILY_GAMES /D_WIN32_WINNT=0x0A00 /D_ATL_NO_DEFAULT_LIBS /D__WRL_NO_DEFAULT_LIB__ /D__WRL_CLASSIC_COM_STRICT__ /D_UITHREADCTXT_SUPPORT=0 /D_CRT_USE_WINAPI_PARTITION_APP")
    set(_vcpkg_common_flags "/nologo /utf-8 /MP /GS /Gd /W3 /WX- /Zc:wchar_t /Zc:inline /Zc:forScope /fp:precise /Oy- /EHsc")

    if(XBOX_CONSOLE_TARGET STREQUAL "scarlett")
        set(VCPKG_TARGET_IS_XBOX ON CACHE BOOL "" FORCE)
        set(VCPKG_TARGET_IS_XBOX_SCARLETT ON CACHE BOOL "" FORCE)

        string(APPEND _vcpkg_cpp_flags " /D_GAMING_XBOX /D_GAMING_XBOX_SCARLETT")
        string(APPEND _vcpkg_cpp_flags " /favor:AMD64 /arch:AVX2")
    elseif(XBOX_CONSOLE_TARGET STREQUAL "xboxone")
        set(VCPKG_TARGET_IS_XBOX ON CACHE BOOL "" FORCE)
        set(VCPKG_TARGET_IS_XBOX_XBOXONE ON CACHE BOOL "" FORCE)

        string(APPEND _vcpkg_cpp_flags " /D_GAMING_XBOX /D_GAMING_XBOX_XBOXONE")
        string(APPEND _vcpkg_cpp_flags " /favor:AMD64 /arch:AVX")
    endif()
    
    set(CMAKE_CXX_FLAGS "${_vcpkg_cpp_flags} ${_vcpkg_common_flags} ${_vcpkg_incpaths} ${VCPKG_CXX_FLAGS}" CACHE STRING "")
    set(CMAKE_C_FLAGS "${_vcpkg_cpp_flags} ${_vcpkg_common_flags} ${_vcpkg_incpaths} ${VCPKG_C_FLAGS}" CACHE STRING "")
    set(CMAKE_RC_FLAGS "-c65001 ${_vcpkg_cpp_flags}" CACHE STRING "")

    unset(_vcpkg_incpaths)
    unset(_vcpkg_cpp_flags)
    unset(_vcpkg_common_flags)

    set(CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Od /RTC1 ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")
    set(CMAKE_C_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Od /RTC1 ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "")

    set(CMAKE_CXX_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG ${VCPKG_CXX_FLAGS_RELEASE}" CACHE STRING "")
    set(CMAKE_C_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "")

    string(APPEND CMAKE_STATIC_LINKER_FLAGS_RELEASE_INIT " /nologo ")

    set(_vcpkg_unsupported advapi32.lib comctl32.lib comsupp.lib dbghelp.lib gdi32.lib gdiplus.lib guardcfw.lib mmc.lib msimg32.lib msvcole.lib msvcoled.lib mswsock.lib ntstrsafe.lib ole2.lib ole2autd.lib ole2auto.lib ole2d.lib ole2ui.lib ole2uid.lib ole32.lib oleacc.lib oleaut32.lib oledlg.lib oledlgd.lib oldnames.lib runtimeobject.lib shell32.lib shlwapi.lib strsafe.lib urlmon.lib user32.lib userenv.lib wlmole.lib wlmoled.lib onecore.lib)
    set (_vcpkg_nodefaultlib "/NODEFAULTLIB:kernel32.lib")
    foreach(arg ${_vcpkg_unsupported})
      string(APPEND _vcpkg_nodefaultlib " /NODEFAULTLIB:${arg}")
    endforeach()

    set(_vcpkg_common_lflags "/MANIFEST:NO /NXCOMPAT /DYNAMICBASE /DEBUG /MANIFESTUAC:NO /SUBSYSTEM:WINDOWS,10.0")

    string(APPEND CMAKE_SHARED_LINKER_FLAGS " ${_vcpkg_common_lflags} ${VCPKG_LINKER_FLAGS} ${_vcpkg_nodefaultlib}")
    string(APPEND CMAKE_EXE_LINKER_FLAGS " ${_vcpkg_common_lflags} ${VCPKG_LINKER_FLAGS} ${_vcpkg_nodefaultlib}")

    unset(_vcpkg_unsupported)
    unset(_vcpkg_nodefaultlib)
    unset(_vcpkg_common_lflags)

    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")
    string(APPEND CMAKE_STATIC_LINKER_FLAGS_DEBUG_INIT " /nologo ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " /nologo ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " /nologo ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_DEBUG} ")
endif()
endif()
