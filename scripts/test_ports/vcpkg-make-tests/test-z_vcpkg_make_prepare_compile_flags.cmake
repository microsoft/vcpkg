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

unit_test_check_variable_equal([[]] CFLAGS_Release "${expected_cflags}")
unit_test_check_variable_equal([[]] CXXFLAGS_Release "${expected_cxxflags}")
unit_test_check_variable_equal([[]] LDFLAGS_Release "${expected_ldflags}")

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

unit_test_check_variable_unset([[]] "${ASMFLAGS_Release}")

set(expected_gcc_cflags "-O2 -DNDEBUG")
unit_test_check_variable_equal([[]] expected_gcc_cflags "${CFLAGS_Release}")

# Test Case 4: No Languages Defined (Should Default to C;CXX)
set(flags_out)
z_vcpkg_make_prepare_compile_flags(
    COMPILER_FRONTEND "MSVC"
    CONFIG "Release"
    FLAGS_OUT flags_out
)

# Verify that both CFLAGS and CXXFLAGS are set since they should default to C and C++
unit_test_check_variable_unset([[]] "${CFLAGS_Release}")
unit_test_check_variable_unset([[]] "${CXXFLAGS_Release}")
