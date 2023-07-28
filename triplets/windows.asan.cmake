include_guard(GLOBAL)

macro(toolchain_set_cmake_policy_new)
if(POLICY ${ARGN})
    cmake_policy(SET ${ARGN} NEW)
endif()
endmacro()
# Setup policies
toolchain_set_cmake_policy_new(CMP0137)
toolchain_set_cmake_policy_new(CMP0128)
toolchain_set_cmake_policy_new(CMP0126)
toolchain_set_cmake_policy_new(CMP0117)
toolchain_set_cmake_policy_new(CMP0092)
toolchain_set_cmake_policy_new(CMP0091)
toolchain_set_cmake_policy_new(CMP0012)
unset(toolchain_set_cmake_policy_new)

option(VCPKG_USE_COMPILER_FOR_LINKAGE "Invoke the compiler for linking instead of the linker" ON)
option(VCPKG_USE_SANITIZERS "Enable sanitizers for release builds" ON)

if(VCPKG_USE_COMPILER_FOR_LINKAGE)
  set(CMAKE_USER_MAKE_RULES_OVERRIDE "${CMAKE_CURRENT_LIST_DIR}/Platform/ASAN-override.cmake")
  set(CMAKE_USER_MAKE_RULES_OVERRIDE_C "${CMAKE_CURRENT_LIST_DIR}/Platform/ASAN-C.cmake")
  set(CMAKE_USER_MAKE_RULES_OVERRIDE_CXX "${CMAKE_CURRENT_LIST_DIR}/Platform/ASAN-CXX.cmake")
endif()

set(_VCPKG_WINDOWS_TOOLCHAIN 1)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:${VCPKG_CRT_LINKAGE},dynamic>:DLL>" CACHE STRING "")
set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "")

set(CMAKE_SYSTEM_NAME Windows CACHE STRING "")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(CMAKE_SYSTEM_PROCESSOR x86 CACHE STRING "")
    set(asan_arch i386)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING "")
    set(asan_arch x86_64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(CMAKE_SYSTEM_PROCESSOR ARM CACHE STRING "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(CMAKE_SYSTEM_PROCESSOR ARM64 CACHE STRING "")
endif()

if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
    set(CMAKE_SYSTEM_VERSION "${VCPKG_CMAKE_SYSTEM_VERSION}" CACHE STRING "" FORCE)
endif()

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    if(CMAKE_SYSTEM_PROCESSOR STREQUAL CMAKE_HOST_SYSTEM_PROCESSOR)
        set(CMAKE_CROSSCOMPILING OFF CACHE STRING "")
    elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86")
        # any of the four platforms can run x86 binaries
        set(CMAKE_CROSSCOMPILING OFF CACHE STRING "")
    elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "ARM64")
        # arm64 can run binaries of any of the four platforms after Windows 11
        set(CMAKE_CROSSCOMPILING OFF CACHE STRING "")
    endif()

    if(NOT DEFINED CMAKE_SYSTEM_VERSION)
        set(CMAKE_SYSTEM_VERSION "${CMAKE_HOST_SYSTEM_VERSION}" CACHE STRING "")
    endif()
endif()

#https://devblogs.microsoft.com/cppblog/asan-for-windows-x64-and-debug-build-support/
#dynamic CRT case is not allowed to have /wholearchive!
set(sanitizer_path "")
set(sanitizer_libs "")
set(sanitizer_libs_exe "")
set(sanitizer_libs_dll "")
message(STATUS "VCPKG_USE_COMPILER_FOR_LINKAGE:${VCPKG_USE_COMPILER_FOR_LINKAGE}")
if(VCPKG_USE_SANITIZERS)
    string(APPEND san_compile_flags "-fsanitize=address /Oy- /GF-")
    if(NOT VCPKG_USE_COMPILER_FOR_LINKAGE)
      if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        # -include:__asan_seh_interceptor <- used by clang
        # /wholearchive: is not used for asan_dynamic by clang. Only the _thunk has wholearchive
        set(sanitizer_libs_exe_rel "/wholearchive:clang_rt.asan_dynamic-${asan_arch}.lib /wholearchive:clang_rt.asan_dynamic_runtime_thunk-${asan_arch}.lib")
        set(sanitizer_libs_dll_rel "${sanitizer_libs_exe_rel}")
        set(sanitizer_libs_exe_dbg "/wholearchive:clang_rt.asan_dbg_dynamic-${asan_arch}.lib /wholearchive:clang_rt.asan_dbg_dynamic_runtime_thunk-${asan_arch}.lib")
        set(sanitizer_libs_dll_dbg "${sanitizer_libs_exe_dbg}")
      else()
        # TODO
        #set(sanitizer_libs "clang_rt.ubsan_standalone-x86_64.lib clang_rt.ubsan_standalone_cxx-x86_64.lib")
        #set(sanitizer_libs_exe "${sanitizer_libs} /wholearchive:clang_rt.asan-x86_64.lib /wholearchive:clang_rt.asan_cxx-x86_64.lib")
        #set(sanitizer_libs_dll "clang_rt.asan_dll_thunk-x86_64.lib")
      endif()
      unset(clang_ver_path)
    endif()
    unset(sanitizers)
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
    set(CHARSET_FLAG)
endif()

set(MP_BUILD_FLAG "")
if(NOT (CMAKE_CXX_COMPILER MATCHES "clang-cl.exe"))
    set(MP_BUILD_FLAG "/MP")
endif()

set(CMAKE_CXX_FLAGS " /nologo /DWIN32 /D_WINDOWS /W3 ${CHARSET_FLAG} /GR /EHsc ${MP_BUILD_FLAG} ${VCPKG_CXX_FLAGS}" CACHE STRING "")
set(CMAKE_C_FLAGS " /nologo /DWIN32 /D_WINDOWS /W3 ${CHARSET_FLAG} ${MP_BUILD_FLAG} ${VCPKG_C_FLAGS}" CACHE STRING "")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64ec")
    string(APPEND CMAKE_CXX_FLAGS " /arm64EC /D_AMD64_ /DAMD64 /D_ARM64EC_ /DARM64EC")
    string(APPEND CMAKE_C_FLAGS " /arm64EC /D_AMD64_ /DAMD64 /D_ARM64EC_ /DARM64EC")
endif()
set(CMAKE_RC_FLAGS "-c65001 /DWIN32" CACHE STRING "")

unset(CHARSET_FLAG)

set(CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od /RTC1 ${VCPKG_CXX_FLAGS_DEBUG} ${san_compile_flags}" CACHE STRING "")
set(CMAKE_C_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od /RTC1 ${VCPKG_C_FLAGS_DEBUG} ${san_compile_flags}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "/DNDEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX} /O1 /Gy /Z7 ${VCPKG_CXX_FLAGS_RELEASE} ${san_compile_flags}" CACHE STRING "")
set(CMAKE_C_FLAGS_RELEASE "/DNDEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX} /O1 /Gy /Z7 ${VCPKG_C_FLAGS_RELEASE} ${san_compile_flags}" CACHE STRING "")

string(APPEND CMAKE_STATIC_LINKER_FLAGS_RELEASE_INIT " /nologo ")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")
set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")

string(APPEND CMAKE_STATIC_LINKER_FLAGS_DEBUG_INIT " /nologo ")
string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " /nologo /DEBUG ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_DEBUG} ${sanitizer_libs_dll_dbg} ")
string(APPEND CMAKE_MODULE_LINKER_FLAGS_DEBUG_INIT " /nologo /DEBUG ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_DEBUG} ${sanitizer_libs_dll_dbg} ")
string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " /nologo /DEBUG ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_DEBUG} ${sanitizer_libs_exe_dbg}")

if(VCPKG_USE_SANITIZERS)
  set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} ${sanitizer_libs_exe_rel}" CACHE STRING "" FORCE)
  set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL} ${sanitizer_libs_exe_rel}" CACHE STRING "" FORCE)
  set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO} ${sanitizer_libs_exe_rel}" CACHE STRING "" FORCE)
  set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} ${sanitizer_libs_dll_rel}" CACHE STRING "" FORCE)
  set(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL "${CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL} ${sanitizer_libs_dll_rel}" CACHE STRING "" FORCE)
  set(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO} ${sanitizer_libs_dll_rel}" CACHE STRING "" FORCE)
  set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "${CMAKE_MODULE_LINKER_FLAGS_RELEASE} ${sanitizer_libs_dll_rel}" CACHE STRING "" FORCE)
  set(CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL "${CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL} ${sanitizer_libs_dll_rel}" CACHE STRING "" FORCE)
  set(CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO} ${sanitizer_libs_dll_rel}" CACHE STRING "" FORCE)
endif()

# Setup try_compile correctly. Requires all variables required by the toolchain. 
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES VCPKG_CRT_LINKAGE 
                                                 VCPKG_C_FLAGS VCPKG_CXX_FLAGS
                                                 VCPKG_C_FLAGS_DEBUG VCPKG_CXX_FLAGS_DEBUG
                                                 VCPKG_C_FLAGS_RELEASE VCPKG_CXX_FLAGS_RELEASE
                                                 VCPKG_LINKER_FLAGS VCPKG_LINKER_FLAGS_RELEASE VCPKG_LINKER_FLAGS_DEBUG
                                                 VCPKG_SET_CHARSET_FLAG
                                                 VCPKG_USE_SANITIZERS
                                                 VCPKG_USE_COMPILER_FOR_LINKAGE
                                                 )
