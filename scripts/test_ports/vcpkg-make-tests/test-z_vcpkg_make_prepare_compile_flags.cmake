set(VCPKG_COMBINED_C_FLAGS_Release "-O2 -DNDEBUG")
set(VCPKG_COMBINED_CXX_FLAGS_Release "-O2 -DNDEBUG")
set(VCPKG_COMBINED_SHARED_LINKER_FLAGS_Release "-L/mylibpath")
set(CURRENT_INSTALLED_DIR "C:/vcpkg_installed/x64-windows")

function(check_flags response_file flags)
  file(READ "${response_file}" content)
  string(REGEX REPLACE "\n" ";" flags_list "${content}")

  foreach(flag ${flags})
    string(FIND "${flags_list}" "${flag}" index)
    if(index EQUAL -1)
      message(FATAL_ERROR "Missing flag '${flag}' in response file '${response_file}'")
    endif()
  endforeach()
endfunction()

# Test Case 1: Basic Flag Generation
set(flags_out)
z_vcpkg_make_prepare_compile_flags(
    COMPILER_FRONTEND "MSVC"
    CONFIG "Release"
    FLAGS_OUT flags_out
    LANGUAGES "C" "CXX"
)

# Expected a response file to be created for cflags, cxxflags, and ldflags
set(expected_rspfile_cflags "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-CFLAGS-Release.rsp")
set(expected_rspfile_cxxflags "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-CXXFLAGS-Release.rsp")
set(expected_rspfile_ldflags "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-LDFLAGS-Release.rsp")
if(NOT EXISTS "${expected_rspfile_cflags}" OR NOT EXISTS "${expected_rspfile_cxxflags}" OR NOT EXISTS "${expected_rspfile_ldflags}")
    message(FATAL_ERROR "Expected response files for CFLAGS, CXXFLAGS, and LDFLAGS not found: ${expected_rspfile_cflags}, ${expected_rspfile_cxxflags}, ${expected_rspfile_ldflags}")
endif()

# Verify the content of the response files
check_flags("${expected_rspfile_cflags}" "-Xcompiler" "-O2" "-Xcompiler" "-DNDEBUG")
check_flags("${expected_rspfile_cxxflags}" "-Xcompiler" "-O2" "-Xcompiler" "-DNDEBUG")
check_flags("${expected_rspfile_ldflags}" "-Xlinker" "-L/mylibpath")

# Test Case 2: Test Case for Use of Response Files and Wrappers
set(flags_out)
z_vcpkg_make_prepare_compile_flags(
    USES_WRAPPERS
    COMPILER_FRONTEND "MSVC"
    CONFIG "Release"
    FLAGS_OUT flags_out
    LANGUAGES "C" "CXX"
)

# Expected a response file to be created for linker flags
set(expected_rspfile_ldflags "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-LDFLAGS-Release.rsp")
if(NOT EXISTS "${expected_rspfile_ldflags}")
    message(FATAL_ERROR "Expected response file for LDFLAGS not found: ${expected_rspfile_ldflags}")
endif()

# Verify the content of the response file
check_flags("${expected_rspfile_ldflags}" "-link")

# Test Case 3: NO_FLAG_ESCAPING (MSVC, Debug)
set(flags_out)
z_vcpkg_make_prepare_compile_flags(
    NO_FLAG_ESCAPING
    COMPILER_FRONTEND "MSVC"
    CONFIG "Debug"
    FLAGS_OUT flags_out
    LANGUAGES "C" "CXX"
)

# Verify flags are not escaped
string(FIND "${CFLAGS_Debug}" "-Xcompiler" index)
if(NOT index EQUAL -1)
    message(FATAL_ERROR "CFLAGS should not include -Xcompiler: ${CFLAGS_Debug}")
endif()

# Test Case 4: Different Languages and Compiler Frontend (GCC)
set(flags_out)
z_vcpkg_make_prepare_compile_flags(
    COMPILER_FRONTEND "GCC"
    CONFIG "Release"
    FLAGS_OUT flags_out
    LANGUAGES "C" "CXX" "ASM"
)

# Verify that ASM flags are set
if(NOT DEFINED ASMFLAGS_Release)
    message(FATAL_ERROR "ASMFLAGS not set for ASM language.")
endif()

set(expected_rspfile_cflags "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-CFLAGS-Release.rsp")
check_flags("${expected_rspfile_cflags}" "-O2" "-DNDEBUG")

# Test Case 5: No Languages Defined (Should Default to C;CXX)
set(flags_out)
z_vcpkg_make_prepare_compile_flags(
    COMPILER_FRONTEND "MSVC"
    CONFIG "Release"
    FLAGS_OUT flags_out
)

# Verify that both CFLAGS and CXXFLAGS are set since they should default to C and C++
if(NOT DEFINED CFLAGS_Release OR NOT DEFINED CXXFLAGS_Release)
    message(FATAL_ERROR "Default languages C or CXX flags are not set as expected.")
endif()