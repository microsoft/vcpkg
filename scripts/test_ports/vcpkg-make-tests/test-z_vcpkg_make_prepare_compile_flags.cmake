set(VCPKG_COMBINED_C_FLAGS_Release "-O2")
set(VCPKG_COMBINED_CXX_FLAGS_Release "-O2")
set(VCPKG_COMBINED_SHARED_LINKER_FLAGS_Release "-L/mylibpath")
set(CURRENT_INSTALLED_DIR "C:/vcpkg_installed/x64-windows")

# Test Case 1: Basic Flag Generation
set(flags_out)
z_vcpkg_make_prepare_compile_flags(
    NO_CPPFLAGS OFF
    NO_FLAG_ESCAPING OFF
    USES_WRAPPERS OFF
    USE_RESPONSE_FILES OFF
    COMPILER_FRONTEND "MSVC"
    CONFIG "Release"
    FLAGS_OUT flags_out
    LANGUAGES "C;CXX"
)

# Known False Assertion to check test mechanism
message(FATAL_ERROR "Known False Assertion Failed.")

# Expected flags based on the function logic
set(expected_cflags "-O2")
set(expected_cxxflags "-O2")
set(expected_ldflags "-L/mylibpath")

# Assertion for CFLAGS
list(FIND "${CFLAGS_Release}" "${expected_cflags}" index)
if(index EQUAL -1)
    message(FATAL_ERROR "CFLAGS did not match expected value: ${CFLAGS_Release} vs ${expected_cflags}")
endif()

# Assertion for CXXFLAGS
list(FIND "${CXXFLAGS_Release}" "${expected_cxxflags}" index)
if(index EQUAL -1)
    message(FATAL_ERROR "CXXFLAGS did not match expected value: ${CXXFLAGS_Release} vs ${expected_cxxflags}")
endif()

# Assertion for LDFLAGS
list(FIND "${LDFLAGS_Release}" "${expected_ldflags}" index)
if(index EQUAL -1)
    message(FATAL_ERROR "LDFLAGS did not match expected value: ${LDFLAGS_Release} vs ${expected_ldflags}")
endif()

# Test Case 2: Test Case for Use of Response Files and Wrappers
set(flags_out)
z_vcpkg_make_prepare_compile_flags(
    USES_WRAPPERS ON
    USE_RESPONSE_FILES ON
    COMPILER_FRONTEND "MSVC"
    CONFIG "Release"
    FLAGS_OUT flags_out
    LANGUAGES "C;CXX"
)

# Expected a response file to be created for linker flags
set(expected_rspfile_ldflags "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-LDFLAGS-Release.rsp")
if(NOT EXISTS "${expected_rspfile_ldflags}")
    message(FATAL_ERROR "Expected response file for LDFLAGS not found: ${expected_rspfile_ldflags}")
endif()

# Verify the content of the response file
file(READ "${expected_rspfile_ldflags}" content_ldflags)
string(FIND "${content_ldflags}" "-link" found_index)
if(found_index EQUAL -1)
    message(FATAL_ERROR "Expected -link in response file for LDFLAGS: ${content_ldflags}")
endif()


# Test Case 3: NO_FLAG_ESCAPING (MSVC, Debug)

set(flags_out)
z_vcpkg_make_prepare_compile_flags(
    NO_FLAG_ESCAPING ON
    COMPILER_FRONTEND "MSVC"
    CONFIG "Debug"
    FLAGS_OUT flags_out
    LANGUAGES "C;CXX"
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
    LANGUAGES "C;CXX;ASM"
)

# Verify that ASM flags are set
if(NOT DEFINED ASMFLAGS_Release)
    message(FATAL_ERROR "ASMFLAGS not set for ASM language.")
endif()

# Expected C and CXX flags for GCC (assuming general flag differences)
set(expected_gcc_cflags "-O2 -fPIC")  # Example, assuming PIC is default for shared libs
list(FIND "${CFLAGS_Release}" "${expected_gcc_cflags}" index)
if(index EQUAL -1)
    message(FATAL_ERROR "CFLAGS for GCC did not match expected value: ${CFLAGS_Release}")
endif()

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
