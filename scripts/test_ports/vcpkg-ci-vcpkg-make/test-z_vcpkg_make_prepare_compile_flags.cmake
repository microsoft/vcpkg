set(VCPKG_COMBINED_C_FLAGS_Release "-O2 -DNDEBUG")
set(VCPKG_COMBINED_CXX_FLAGS_Release "-O2 -DNDEBUG")
set(VCPKG_COMBINED_C_FLAGS_Debug "-g -O0 -DDEBUG")
set(VCPKG_COMBINED_CXX_FLAGS_Debug "-g -O0 -DDEBUG")
set(VCPKG_COMBINED_SHARED_LINKER_FLAGS_Release "-L/mylibpath")
set(VCPKG_COMBINED_SHARED_LINKER_FLAGS_Debug "-L/debuglibpath")
set(CURRENT_INSTALLED_DIR "C:/vcpkg_installed/x64-windows")

# Test Case: Release Flag Generation
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


# Test Case: Debug flag generation
set(flags_out)
z_vcpkg_make_prepare_compile_flags(
    COMPILER_FRONTEND "MSVC"
    CONFIG "Debug"
    FLAGS_OUT flags_out
    LANGUAGES "C" "CXX"
)

# Expected Debug flags
set(expected_cflags "-Xcompiler -g -Xcompiler -O0 -Xcompiler -DDEBUG")  
set(expected_cxxflags "-Xcompiler -g -Xcompiler -O0 -Xcompiler -DDEBUG")
set(expected_ldflags "-Xlinker -Xlinker -Xlinker -L/debuglibpath")

# Check the values of the Debug flags
unit_test_check_variable_equal([[]] CFLAGS_Debug "${expected_cflags}")
unit_test_check_variable_equal([[]] CXXFLAGS_Debug "${expected_cxxflags}")
unit_test_check_variable_equal([[]] LDFLAGS_Debug "${expected_ldflags}")

# Test Case: NO_FLAG_ESCAPING (MSVC, Debug)
set(flags_out)
unset(CFLAGS_Debug)
unset(CXXFLAGS_Debug)
unset(LDFLAGS_Debug)
z_vcpkg_make_prepare_compile_flags(
    NO_FLAG_ESCAPING
    COMPILER_FRONTEND "MSVC"
    CONFIG "Debug"
    FLAGS_OUT flags_out
    LANGUAGES "C" "CXX"
)

set(expected_cflags "-g -O0 -DDEBUG")  
set(expected_cxxflags "-g -O0 -DDEBUG")
set(expected_ldflags "-L/debuglibpath")

unit_test_check_variable_equal([[]] CFLAGS_Debug "${expected_cflags}")
unit_test_check_variable_equal([[]] CXXFLAGS_Debug "${expected_cxxflags}")
unit_test_check_variable_equal([[]] LDFLAGS_Debug "${expected_ldflags}")

# Test Case: Different Languages and Compiler Frontend (GCC)
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

# Test Case: No Languages Defined (Should Default to C;CXX)
set(flags_out)
unset(CFLAGS_Release)
unset(CXXFLAGS_Release)
unset(LDFLAGS_Release)
unset(ASMFLAGS_Release)
z_vcpkg_make_prepare_compile_flags(
    COMPILER_FRONTEND "MSVC"
    CONFIG "Release"
    FLAGS_OUT flags_out
)

# Verify that both CFLAGS and CXXFLAGS are set since they should default to C and C++
if(NOT CFLAGS_Release)
    message(FATAL_ERROR "CFLAGS_Release not set")
endif()

if(NOT CXXFLAGS_Release)
    message(FATAL_ERROR "CXXFLAGS_Release not set")
endif()