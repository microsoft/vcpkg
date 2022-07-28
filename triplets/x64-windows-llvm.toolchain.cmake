include_guard(GLOBAL)

function(get_vcpkg_triplet_variables)
  include("${CMAKE_CURRENT_LIST_DIR}/${VCPKG_TARGET_TRIPLET}.cmake")
  # Be carefull here you don't want to pull in all variables from the triplet!
  # Port is not defined!
  set(VCPKG_CRT_LINKAGE "${VCPKG_CRT_LINKAGE}" PARENT_SCOPE) # This is also forwarded by vcpkg itself
endfunction()

get_vcpkg_triplet_variables()
# Set C standard.
# set(CMAKE_C_STANDARD 11 CACHE STRING "")
# set(CMAKE_C_STANDARD_REQUIRED ON CACHE STRING "")
# set(CMAKE_C_EXTENSIONS ON CACHE STRING "")
# set(std_c_flags "-std:c11") #/Zc:__STDC__

# Set C++ standard.
# set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
# set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE STRING "")
# set(CMAKE_CXX_EXTENSIONS OFF CACHE STRING "")
# set(std_cxx_flags "/permissive- -std:c++20 /Zc:__cplusplus")

# Set Windows definitions:
set(windows_defs "/DWIN32 /D_WIN64 /D_WINDOWS /D_WIN32_WINNT=0x0A00 /DWINVER=0x0A00")
string(APPEND windows_defs " /D_CRT_SECURE_NO_DEPRECATE /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_DEPRECATE")
string(APPEND windows_defs " /D_ATL_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_WARNINGS")

# Set runtime library.
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:${VCPKG_CRT_LINKAGE},dynamic>:DLL>" CACHE STRING "")
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  set(VCPKG_CRT_FLAG "/MD")
  set(VCPKG_DBG_FLAG "/Z7 /Brepro")
elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
  set(VCPKG_CRT_FLAG "/MT")
  set(VCPKG_DBG_FLAG "/Z7 /Brepro")
else()
  message(FATAL_ERROR "Invalid VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\".")
endif()

# Set charset flag.
set(CHARSET_FLAG "/utf-8")
if(DEFINED VCPKG_SET_CHARSET_FLAG AND NOT VCPKG_SET_CHARSET_FLAG)
  set(CHARSET_FLAG "")
endif()

set(CMAKE_CL_NOLOGO "/nologo" CACHE STRING "")

# Set compiler flags.
set(CLANG_FLAGS "/clang:-fasm /clang:-fopenmp-simd")

# Setup try_compile correctly. 
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES VCPKG_CRT_LINKAGE 
                                                 VCPKG_C_FLAGS VCPKG_CXX_FLAGS
                                                 VCPKG_C_FLAGS_DEBUG VCPKG_CXX_FLAGS_DEBUG
                                                 VCPKG_C_FLAGS_RELEASE VCPKG_CXX_FLAGS_RELEASE
                                                 VCPKG_LINKER_FLAGS VCPKG_LINKER_FLAGS_RELEASE VCPKG_LINKER_FLAGS_DEBUG
                                                 VCPKG_SET_CHARSET_FLAG
                                                 )


# Set compiler.
find_program(CLANG-CL_EXECUTBALE NAMES "clang-cl" "clang-cl.exe" PATHS ENV LLVMInstallDir PATH_SUFFIXES "bin" NO_DEFAULT_PATH)
find_program(CLANG-CL_EXECUTBALE NAMES "clang-cl" "clang-cl.exe" PATHS ENV LLVMInstallDir PATH_SUFFIXES "bin" )

if(NOT CLANG-CL_EXECUTBALE)
  message(SEND_ERROR "clang-cl was not found!") # Not a FATAL_ERROR due to being a toolchain!
endif()

get_filename_component(LLVM_BIN_DIR "${CLANG-CL_EXECUTBALE}" DIRECTORY)
list(INSERT CMAKE_PROGRAM_PATH 0 "${LLVM_BIN_DIR}")

set(CMAKE_C_COMPILER "${CLANG-CL_EXECUTBALE}" CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER "${CLANG-CL_EXECUTBALE}" CACHE STRING "" FORCE)
if(VCPKG_IS_MAKE_PORT)
    set(CMAKE_AR "lib.exe" CACHE STRING "" FORCE)
else()
    set(CMAKE_AR "${LLVM_BIN_DIR}/llvm-lib.exe" CACHE STRING "" FORCE)
endif()
set(CMAKE_LINKER "${LLVM_BIN_DIR}/lld-link.exe" CACHE STRING "" FORCE) 

#set(CMAKE_LINKER "link.exe" CACHE STRING "" FORCE)
set(CMAKE_ASM_MASM_COMPILER "ml64.exe" CACHE STRING "" FORCE)
#set(CMAKE_RC_COMPILER "${LLVM_BIN_DIR}/llvm-rc.exe" CACHE STRING "" FORCE)
set(CMAKE_RC_COMPILER "rc.exe" CACHE STRING "" FORCE)
set(CMAKE_MT "mt.exe" CACHE STRING "" FORCE)

set(CMAKE_C_FLAGS "${CMAKE_CL_NOLOGO} ${windows_defs} -mcrc32 -msse4.2 ${VCPKG_C_FLAGS} ${CLANG_FLAGS} ${CHARSET_FLAG} ${std_c_flags}" CACHE STRING "")
set(CMAKE_C_FLAGS_DEBUG "/Od /Ob0 /GS /RTC1 /FC ${VCPKG_C_FLAGS_DEBUG} ${VCPKG_CRT_FLAG}d ${VCPKG_DBG_FLAG} /D_DEBUG" CACHE STRING "")
set(CMAKE_C_FLAGS_RELEASE "/O2 /Oi /Ob2 /GS- ${VCPKG_C_FLAGS_RELEASE} ${VCPKG_CRT_FLAG} ${CLANG_C_LTO_FLAGS} ${VCPKG_DBG_FLAG} /DNDEBUG" CACHE STRING "")
set(CMAKE_C_FLAGS_MINSIZEREL "/O1 /Oi /Ob1 /GS- ${VCPKG_C_FLAGS_RELEASE} ${VCPKG_CRT_FLAG} ${CLANG_C_LTO_FLAGS} /DNDEBUG" CACHE STRING "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "/O2 /Oi /Ob1 /GS- ${VCPKG_C_FLAGS_RELEASE} ${VCPKG_CRT_FLAG} ${CLANG_C_LTO_FLAGS} ${VCPKG_DBG_FLAG} /DNDEBUG" CACHE STRING "")

set(CMAKE_CXX_FLAGS "${CMAKE_CL_NOLOGO} ${windows_defs} -mcrc32 -msse4.2 /EHsc /GR ${VCPKG_CXX_FLAGS} ${CLANG_FLAGS} ${CHARSET_FLAG} ${std_cxx_flags}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /FC ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} ${VCPKG_CXX_FLAGS_RELEASE} ${CLANG_CXX_LTO_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} ${VCPKG_CXX_FLAGS_RELEASE} ${CLANG_CXX_LTO_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} ${VCPKG_CXX_FLAGS_RELEASE} ${CLANG_CXX_LTO_FLAGS}" CACHE STRING "")

# Set linker flags.
foreach(LINKER SHARED_LINKER MODULE_LINKER EXE_LINKER)
  set(CMAKE_${LINKER}_FLAGS_INIT "/Brepro ${VCPKG_LINKER_FLAGS}")
  set(CMAKE_${LINKER}_FLAGS_DEBUG "/INCREMENTAL:NO /DEBUG:FULL ${VCPKG_LINKER_FLAGS_DEBUG}" CACHE STRING "")
  set(CMAKE_${LINKER}_FLAGS_RELEASE "/OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")
  set(CMAKE_${LINKER}_FLAGS_MINSIZEREL "/OPT:REF /OPT:ICF" CACHE STRING "")
  set(CMAKE_${LINKER}_FLAGS_RELWITHDEBINFO "/OPT:REF /OPT:ICF /DEBUG:FULL" CACHE STRING "")
endforeach()

# Set assembler flags.
set(CMAKE_ASM_MASM_FLAGS_INIT "${CMAKE_CL_NOLOGO}")

# Set resource compiler flags.
set(CMAKE_RC_FLAGS_INIT "-c65001 ${windows_defs}")
set(CMAKE_RC_FLAGS_DEBUG_INIT "-D_DEBUG")

unset(CHARSET_FLAG)
unset(CLANG_FLAGS)
unset(CLANG_C_LTO_FLAGS)
unset(CLANG_CXX_LTO_FLAGS)
unset(windows_defs)
unset(std_c_flags)
unset(VCPKG_DBG_FLAG)
unset(VCPKG_CRT_FLAG)

