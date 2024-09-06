set(VCPKG_COMBINED_C_FLAGS_Release "-O2 -DNDEBUG")
set(VCPKG_COMBINED_CXX_FLAGS_Release "-O2 -DNDEBUG")
set(VCPKG_COMBINED_SHARED_LINKER_FLAGS_Release "-L/mylibpath")
set(CURRENT_INSTALLED_DIR "C:/vcpkg_installed/x64-windows")

# Test Case 1: Basic Flag Generation
set(flags_out)
z_vcpkg_make_prepare_compile_flags(
    COMPILER_FRONTEND "MSVC"
    CONFIG "Release"
    FLAGS_OUT flags_out
    LANGUAGES "C" "CXX"
)

set(expected_cflags "-Xcompiler -O2 -Xcompiler -DNDEBUG")  
set(expected_cxxflags "-Xcompiler -O2 -Xcompiler -DNDEBUG")
set(expected_ldflags "-Xlinker -Xlinker -Xlinker -L/mylibpath")

message(STATUS "linker_flag_escape: ${linker_flag_escape}")
message(STATUS "VCPKG_COMBINED_SHARED_LINKER_FLAGS_Release: ${VCPKG_COMBINED_SHARED_LINKER_FLAGS_Release}")
message(STATUS "LDFLAGS: ${LDFLAGS_Release}")

if(NOT "${CFLAGS_Release}" STREQUAL "${expected_cflags}")
    message(FATAL_ERROR "CFLAGS did not match expected value: ${CFLAGS_Release} vs ${expected_cflags}")
endif()

if(NOT "${CXXFLAGS_Release}" STREQUAL "${expected_cxxflags}")
    message(FATAL_ERROR "CXXFLAGS did not match expected value: ${CXXFLAGS_Release} vs ${expected_cxxflags}")
endif()

if(NOT "${LDFLAGS_Release}" STREQUAL "${expected_ldflags}")
    message(FATAL_ERROR "LDFLAGS did not match expected value: ${LDFLAGS_Release} vs ${expected_ldflags}")
endif()


# Test Case 2: NO_FLAG_ESCAPING (MSVC, Debug)
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

# Test Case 3: Different Languages and Compiler Frontend (GCC)
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

# Expected C and CXX flags for GCC (assuming general flag differences)
# Convert lists to strings (if necessary) and ensure there are no extra spaces
# Note: Encountered weird comparison issue 
#  was failing with "CFLAGS for GCC did not match expected value: -O2 -DNDEBUG vs -O2 -DNDEBUG"
set(expected_gcc_cflags "-O2 -DNDEBUG")
string(REPLACE ";" " " cflags_normalized "${CFLAGS_Release}")
string(STRIP "${cflags_normalized}" cflags_normalized)
string(STRIP "${expected_gcc_cflags}" expected_normalized)

if(NOT "${cflags_normalized}" STREQUAL "${expected_normalized}")
    message(FATAL_ERROR "CFLAGS for GCC did not match expected value: ${CFLAGS_Release} vs ${expected_gcc_cflags}")
endif()

# Test Case 4: No Languages Defined (Should Default to C;CXX)
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
