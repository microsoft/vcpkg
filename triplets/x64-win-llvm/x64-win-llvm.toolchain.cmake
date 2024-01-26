include_guard(GLOBAL)

option(VCPKG_USE_COMPILER_FOR_LINKAGE "Invoke the compiler for linking instead of the linker" OFF)
option(VCPKG_USE_LTO "Enable full LTO for release builds" OFF)
option(VCPKG_USE_SANITIZERS "Enable sanitizers for release builds" OFF)

if(VCPKG_USE_COMPILER_FOR_LINKAGE)
  set(CMAKE_USER_MAKE_RULES_OVERRIDE "${CMAKE_CURRENT_LIST_DIR}/Platform/Clang-CL-override.cmake")
  set(CMAKE_USER_MAKE_RULES_OVERRIDE_C "${CMAKE_CURRENT_LIST_DIR}/Platform/Clang-CL-C.cmake")
  set(CMAKE_USER_MAKE_RULES_OVERRIDE_CXX "${CMAKE_CURRENT_LIST_DIR}/Platform/Clang-CL-CXX.cmake")
endif()

function(get_vcpkg_triplet_variables)
  include("${CMAKE_CURRENT_LIST_DIR}/../${VCPKG_TARGET_TRIPLET}.cmake")
  # Be carefull here you don't want to pull in all variables from the triplet!
  # Port is not defined!
  set(VCPKG_CRT_LINKAGE "${VCPKG_CRT_LINKAGE}" PARENT_SCOPE) # This is also forwarded by vcpkg itself
endfunction()

get_vcpkg_triplet_variables()

set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "Embedded")

# Set C standard.
set(CMAKE_C_STANDARD 11 CACHE STRING "")
set(CMAKE_C_STANDARD_REQUIRED ON CACHE STRING "")
set(CMAKE_C_EXTENSIONS ON CACHE STRING "")
set(std_c_flags "-std:c11 -D__STDC__=1 -Wno-implicit-function-declaration") #/Zc:__STDC__
# -Wno-implicit-function-declaration because a lot of libraries don't #include <io.h> 
# for read/open/access and clang 16 made that an error instead of a warning.

# Set C++ standard.
#set(CMAKE_CXX_STANDARD 17 CACHE STRING "")
#set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE STRING "")
#set(CMAKE_CXX_EXTENSIONS OFF CACHE STRING "")
# set(std_cxx_flags "/permissive- -std:c++20 /Zc:__cplusplus")
#set(std_cxx_flags "/permissive- -std:c++17 /Zc:__cplusplus -Wno-register")

# Set Windows definitions:
set(windows_defs "/DWIN32")
if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  string(APPEND windows_defs " /D_WIN64")
endif()
string(APPEND windows_defs " /D_WIN32_WINNT=0x0A00 /DWINVER=0x0A00") # tweak for targeted windows
string(APPEND windows_defs " /D_CRT_SECURE_NO_DEPRECATE /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_DEPRECATE")
string(APPEND windows_defs " /D_ATL_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_WARNINGS")
string(APPEND windows_defs " /D_CRT_INTERNAL_NONSTDC_NAMES /D_CRT_DECLARE_NONSTDC_NAMES") # due to -D__STDC__=1 required for e.g. _fopen -> fopen and other not underscored functions/defines
string(APPEND windows_defs " /D_FORCENAMELESSUNION") # Due to -D__STDC__ to access tagVARIANT members (ffmpeg)

# Try to ignore /WX and -werror; A lot of ports mess up the compiler detection and add wrong flags!
set(ignore_werror "/WX-")
cmake_language(DEFER CALL add_compile_options "/WX-") # make sure the flag is added at the end!

# general architecture flags
# set(arch_flags "-mcrc32 -msse4.2 -maes -mpclmul")
# -mcrc32 for libpq
# -mrtm for tbb (will break qtdeclarative since it cannot run the executables in CI)
# -msse4.2 for everything which normally cl can use. (Otherwise strict sse2 only.)
# -maes -mpclmul mbedtls
if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
  string(APPEND arch_flags " -m32 --target=i686-pc-windows-msvc")
endif()
# /Za unknown

# Set runtime library.
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:${VCPKG_CRT_LINKAGE},dynamic>:DLL>" CACHE STRING "")
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  set(VCPKG_CRT_FLAG "/MD")
elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
  set(VCPKG_CRT_FLAG "/MT")
else()
  message(FATAL_ERROR "Invalid VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\".")
endif()
set(VCPKG_DBG_FLAG "/Z7 /Brepro") # clang-cl only supports /Z7
 
# Set charset flag.
set(CHARSET_FLAG "/utf-8")
if(DEFINED VCPKG_SET_CHARSET_FLAG AND NOT VCPKG_SET_CHARSET_FLAG)
  set(CHARSET_FLAG "")
endif()

set(CMAKE_CL_NOLOGO "/nologo" CACHE STRING "")

# Set compiler.
find_program(CLANG-CL_EXECUTBALE NAMES "clang-cl" "clang-cl.exe" PATHS ENV LLVMInstallDir PATH_SUFFIXES "bin" NO_DEFAULT_PATH)
find_program(CLANG-CL_EXECUTBALE NAMES "clang-cl" "clang-cl.exe" PATHS ENV LLVMInstallDir PATH_SUFFIXES "bin" )

find_program(CLANG_EXECUTBALE NAMES "clang" "clang.exe" PATHS ENV LLVMInstallDir PATH_SUFFIXES "bin" NO_DEFAULT_PATH)
find_program(CLANG_EXECUTBALE NAMES "clang" "clang.exe" PATHS ENV LLVMInstallDir PATH_SUFFIXES "bin")

if(NOT CLANG-CL_EXECUTBALE)
  message(SEND_ERROR "clang-cl was not found!") # Not a FATAL_ERROR due to being a toolchain!
endif()

get_filename_component(LLVM_BIN_DIR "${CLANG-CL_EXECUTBALE}" DIRECTORY)
list(INSERT CMAKE_PROGRAM_PATH 0 "${LLVM_BIN_DIR}")

set(CMAKE_C_COMPILER "${CLANG-CL_EXECUTBALE}" CACHE STRING "")
set(CMAKE_CXX_COMPILER "${CLANG-CL_EXECUTBALE}" CACHE STRING "")
set(CMAKE_AR "${LLVM_BIN_DIR}/llvm-lib.exe" CACHE STRING "")
#set(CMAKE_AR "${LLVM_BIN_DIR}/llvm-ar.exe" CACHE STRING "")
#set(CMAKE_RANLIB "${LLVM_BIN_DIR}/llvm-ranlib.exe" CACHE STRING "")
set(CMAKE_LINKER "${LLVM_BIN_DIR}/lld-link.exe" CACHE STRING "")
#set(CMAKE_LINKER "${CLANG-CL_EXECUTBALE}" CACHE STRING "")
#set(CMAKE_LINKER "link.exe" CACHE STRING "" FORCE)
set(CMAKE_ASM_MASM_COMPILER "ml64.exe" CACHE STRING "")
#set(CMAKE_RC_COMPILER "${LLVM_BIN_DIR}/llvm-rc.exe" CACHE STRING "" FORCE)
set(CMAKE_RC_COMPILER "rc.exe" CACHE STRING "")
set(CMAKE_MT "mt.exe" CACHE STRING "")

#set(CMAKE_USER_MAKE_RULES_OVERRIDE_CUDA "${CMAKE_CURRENT_LIST_DIR}/Platform/Windows-Clang-CUDA.cmake")
#set(CMAKE_CUDA_COMPILER "${CLANG_EXECUTBALE}")
#set(CMAKE_CUDA_HOST_COMPILER "${CLANG_EXECUTBALE}")
#https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/
#set(CMAKE_CUDA_ARCHITECTURES 60 )
#set(_CMAKE_CUDA_WHOLE_FLAG "-c")
#set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -D_WIN32 -DNDEBUG -O2 --no-cuda-version-check") # --cuda-gpu-arch=sm_60" --cuda-path=${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/cuda")
#string(APPEND CMAKE_CUDA_FLAGS " -Xcompiler -fuse-ld=lld-link -Xcompiler -std=c++17") #-cl-version v143 #  -use-local-env
#set(CMAKE_CUDA_COMPILER_TOOLKIT_ROOT "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/cuda")
#set(CUDAToolkit_ROOT "${CUDATOOLKIT_ROOT}")
    #set(CMAKE_CUDA_DEVICE_LINKER "${CMAKE_CUDA_COMPILER_TOOLKIT_ROOT}/bin/nvlink${CMAKE_EXECUTABLE_SUFFIX}")
    #set(CMAKE_CUDA_FATBINARY "${CMAKE_CUDA_COMPILER_TOOLKIT_ROOT}/bin/fatbinary${CMAKE_EXECUTABLE_SUFFIX}")

### CUDA section nvcc

if(NOT CUDA_C_COMPILER)
  # Due to nvcc error   : 'cudafe++' died with status 0xC0000409 |  clang-cl cannot currently be used to compile cu files.
  # The CUDA frontend probably has problems parsing preprocessed files from clang-cl
  find_program(CL_COMPILER NAMES cl)
  set(CUDA_C_COMPILER "${CL_COMPILER}")
endif()

string(APPEND CMAKE_CUDA_FLAGS " --keep --use-local-env --allow-unsupported-compiler -ccbin \"${CUDA_C_COMPILER}\"")
set(CUDA_HOST_COMPILER "${CUDA_C_COMPILER}")
set(CMAKE_CUDA_HOST_COMPILER "${CUDA_C_COMPILER}")
### CUDA section clang (requires cmake changes)

#set(CMAKE_USER_MAKE_RULES_OVERRIDE_CUDA "${CMAKE_CURRENT_LIST_DIR}/Platform/Windows-Clang-CUDA.cmake")
#set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -D_WIN32 -DNDEBUG -O2 --no-cuda-version-check") # --cuda-gpu-arch=sm_60" --cuda-path=${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/cuda")

###



# Set compiler flags.
#set(CLANG_FLAGS "/clang:-fasm -fmacro-backtrace-limit=0") #/clang:-fopenmp-simd -openmp

set(CLANG_C_LTO_FLAGS "-fuse-ld=lld-link")
set(CLANG_CXX_LTO_FLAGS "-fuse-ld=lld-link")
if(VCPKG_USE_LTO)
  set(CLANG_C_LTO_FLAGS "-flto -fuse-ld=lld-link")
  set(CLANG_CXX_LTO_FLAGS "-flto -fuse-ld=lld-link -fwhole-program-vtables")
endif()

#https://devblogs.microsoft.com/cppblog/asan-for-windows-x64-and-debug-build-support/
#dynamic CRT case is not allowed to have /wholearchive!
set(sanitizer_path "")
set(sanitizer_libs "")
set(sanitizer_libs_exe "")
set(sanitizer_libs_dll "")
message(STATUS "VCPKG_USE_COMPILER_FOR_LINKAGE:${VCPKG_USE_COMPILER_FOR_LINKAGE}")
if(VCPKG_USE_SANITIZERS)
    set(sanitizers "alignment,null")
    if(VCPKG_USE_LTO)
      string(APPEND sanitizers ",cfi")
    else()
      string(APPEND sanitizers ",address") # lld-link: error: /alternatename: conflicts: __sanitizer_on_print=__sanitizer_on_print__def
    endif()
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
      string(APPEND sanitizers ",undefined")
    endif()
    string(APPEND CLANG_FLAGS_RELEASE "-fsanitize=${sanitizers} /Oy- /GF-")
    if(NOT DEFINED ENV{LLVMToolsVersion})
      file(GLOB clang_ver_path LIST_DIRECTORIES true "${LLVM_BIN_DIR}/../lib/clang/*")
    else()
      set(clang_ver_path "${LLVM_BIN_DIR}/../lib/clang/$ENV{LLVMToolsVersion}")
    endif()
    #set(ENV{PATH} "$ENV{PATH};${clang_ver_path}/lib/windows")
    
    if(NOT VCPKG_USE_COMPILER_FOR_LINKAGE)
      #set(ENV{LINK} "$ENV{LINK} /LIBPATH:\"${clang_ver_path}/lib/windows\"")
      #set(sanitizer_path "/LIBPATH:\\\\\"${clang_ver_path}/lib/windows\\\\\"" )
      if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(sanitizer_libs_exe "-include:__asan_seh_interceptor clang_rt.asan_dynamic-x86_64.lib clang_rt.asan_dynamic_runtime_thunk-x86_64.lib /wholearchive:clang_rt.asan_dynamic_runtime_thunk-x86_64.lib")
        set(sanitizer_libs_dll "${sanitizer_libs_exe}")
      else()
        set(sanitizer_libs "clang_rt.ubsan_standalone-x86_64.lib clang_rt.ubsan_standalone_cxx-x86_64.lib")
        set(sanitizer_libs_exe "${sanitizer_libs} /wholearchive:clang_rt.asan-x86_64.lib /wholearchive:clang_rt.asan_cxx-x86_64.lib")
        set(sanitizer_libs_dll "clang_rt.asan_dll_thunk-x86_64.lib")
      endif()
      unset(clang_ver_path)
    endif()
    unset(sanitizers)
endif()

set(CMAKE_C_FLAGS "${CMAKE_CL_NOLOGO} ${windows_defs} ${arch_flags} ${VCPKG_C_FLAGS} ${CLANG_FLAGS} ${CHARSET_FLAG} ${std_c_flags} ${ignore_werror}" CACHE STRING "")
set(CMAKE_C_FLAGS_DEBUG "/Od /Ob0 /GS /RTC1 /FC ${VCPKG_C_FLAGS_DEBUG} ${VCPKG_CRT_FLAG}d ${VCPKG_DBG_FLAG} /D_DEBUG" CACHE STRING "")
set(CMAKE_C_FLAGS_RELEASE "/O2 /Oi ${CLANG_FLAGS_RELEASE} ${VCPKG_C_FLAGS_RELEASE} ${VCPKG_CRT_FLAG} ${CLANG_C_LTO_FLAGS} ${VCPKG_DBG_FLAG} /DNDEBUG" CACHE STRING "")
set(CMAKE_C_FLAGS_MINSIZEREL "/O1 /Oi /Ob1 /GS- ${CLANG_FLAGS_RELEASE} ${VCPKG_C_FLAGS_RELEASE} ${VCPKG_CRT_FLAG} ${CLANG_C_LTO_FLAGS} /DNDEBUG" CACHE STRING "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "/O2 /Oi /Ob1 /GS- ${CLANG_FLAGS_RELEASE} ${VCPKG_C_FLAGS_RELEASE} ${VCPKG_CRT_FLAG} ${CLANG_C_LTO_FLAGS} ${VCPKG_DBG_FLAG} /DNDEBUG" CACHE STRING "")

set(CMAKE_CXX_FLAGS "${CMAKE_CL_NOLOGO} /EHsc /GR ${windows_defs} ${arch_flags} ${VCPKG_CXX_FLAGS} ${CLANG_FLAGS} ${CHARSET_FLAG} ${std_cxx_flags} ${ignore_werror}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /FC ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} ${VCPKG_CXX_FLAGS_RELEASE} ${CLANG_CXX_LTO_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} ${VCPKG_CXX_FLAGS_RELEASE} ${CLANG_CXX_LTO_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} ${VCPKG_CXX_FLAGS_RELEASE} ${CLANG_CXX_LTO_FLAGS}" CACHE STRING "")

# Remove duplicated whitespaces
foreach(flag_suf IN ITEMS ";_DEBUG;_RELEASE;_MINSIZEREL;_RELWITHDEBINFO")
    string(REGEX REPLACE " +" " " CMAKE_C_FLAGS${flag} "${CMAKE_C_FLAGS${flag}}")
    string(REGEX REPLACE " +" " " CMAKE_CXX_FLAGS${flag} "${CMAKE_CXX_FLAGS${flag}}")
endforeach()
unset(flag_suf)

# Set linker flags.
foreach(linker IN ITEMS "SHARED" "MODULE" "EXE")
  set(CMAKE_${linker}_LINKER_FLAGS_INIT "${CMAKE_CL_NOLOGO} /INCREMENTAL:NO /Brepro ${VCPKG_LINKER_FLAGS}" CACHE STRING "")
  set(CMAKE_${linker}_LINKER_FLAGS "${CMAKE_CL_NOLOGO} /INCREMENTAL:NO /Brepro ${VCPKG_LINKER_FLAGS}" CACHE STRING "")
  set(CMAKE_${linker}_LINKER_FLAGS_DEBUG "/DEBUG:FULL ${VCPKG_LINKER_FLAGS_DEBUG}" CACHE STRING "")
  set(CMAKE_${linker}_LINKER_FLAGS_RELEASE "/DEBUG /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS_RELEASE} ${sanitizer_path} ${sanitizer_libs}" CACHE STRING "")
  set(CMAKE_${linker}_LINKER_FLAGS_MINSIZEREL "/DEBUG /OPT:REF /OPT:ICF ${sanitizer_path} ${sanitizer_libs}" CACHE STRING "")
  set(CMAKE_${linker}_LINKER_FLAGS_RELWITHDEBINFO "/DEBUG:FULL /OPT:REF /OPT:ICF ${sanitizer_path} ${sanitizer_libs}" CACHE STRING "")
endforeach()
unset(sanitizer_path)
unset(sanitizer_libs)

if(VCPKG_USE_SANITIZERS)
  set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} ${sanitizer_libs_exe}" CACHE STRING "" FORCE)
  set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL} ${sanitizer_libs_exe}" CACHE STRING "" FORCE)
  set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO} ${sanitizer_libs_exe}" CACHE STRING "" FORCE)
  set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} ${sanitizer_libs_dll}" CACHE STRING "" FORCE)
  set(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL "${CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL} ${sanitizer_libs_dll}" CACHE STRING "" FORCE)
  set(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO} ${sanitizer_libs_dll}" CACHE STRING "" FORCE)
  set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "${CMAKE_MODULE_LINKER_FLAGS_RELEASE} ${sanitizer_libs_dll}" CACHE STRING "" FORCE)
  set(CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL "${CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL} ${sanitizer_libs_dll}" CACHE STRING "" FORCE)
  set(CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO} ${sanitizer_libs_dll}" CACHE STRING "" FORCE)
endif()
unset(sanitizer_libs_dll)
unset(sanitizer_libs_exe)

foreach(lang IN ITEMS C CXX)
  foreach(linker IN ITEMS "SHARED" "MODULE" "EXE")
    set(CMAKE_${lang}_${linker}_LINKER_FLAGS "${CMAKE_${linker}_LINKER_FLAGS}" CACHE STRING "")
    set(CMAKE_${lang}_${linker}_LINKER_FLAGS_DEBUG "${CMAKE_${linker}_LINKER_FLAGS_DEBUG}" CACHE STRING "")
    set(CMAKE_${lang}_${linker}_LINKER_FLAGS_RELEASE "${CMAKE_${linker}_LINKER_FLAGS_RELEASE}" CACHE STRING "")
    set(CMAKE_${lang}_${linker}_LINKER_FLAGS_MINSIZEREL "${CMAKE_${linker}_LINKER_FLAGS_MINSIZEREL}" CACHE STRING "")
    set(CMAKE_${lang}_${linker}_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_${linker}_LINKER_FLAGS_RELWITHDEBINFO}" CACHE STRING "")
  endforeach()
endforeach()
unset(linker)
unset(lang)

# Set assembler flags.
set(CMAKE_ASM_MASM_FLAGS_INIT "${CMAKE_CL_NOLOGO}")

# Set resource compiler flags.
set(CMAKE_RC_FLAGS_INIT "-c65001 ${windows_defs}")
set(CMAKE_RC_FLAGS_DEBUG_INIT "-D_DEBUG")

# Setup try_compile correctly. Requires all variables required by the toolchain. 
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES VCPKG_CRT_LINKAGE 
                                                 VCPKG_C_FLAGS VCPKG_CXX_FLAGS
                                                 VCPKG_C_FLAGS_DEBUG VCPKG_CXX_FLAGS_DEBUG
                                                 VCPKG_C_FLAGS_RELEASE VCPKG_CXX_FLAGS_RELEASE
                                                 VCPKG_LINKER_FLAGS VCPKG_LINKER_FLAGS_RELEASE VCPKG_LINKER_FLAGS_DEBUG
                                                 VCPKG_SET_CHARSET_FLAG
                                                 VCPKG_USE_SANITIZERS
                                                 VCPKG_USE_LTO
                                                 )
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

# Remove variables which are not needed anymore
unset(CHARSET_FLAG)
unset(CLANG_FLAGS)
unset(CLANG_C_LTO_FLAGS)
unset(CLANG_CXX_LTO_FLAGS)
unset(windows_defs)
unset(std_c_flags)
unset(ignore_werror)
unset(arch_flags)
unset(VCPKG_DBG_FLAG)
unset(VCPKG_CRT_FLAG)
