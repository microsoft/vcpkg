set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(VCPKG_HOST_IS_WINDOWS)
    # The version-agnostic tool dir may already exist.
    # Simulate/test with NASM.
    file(REMOVE_RECURSE "${DOWNLOADS}/tools/nasm")
    file(MAKE_DIRECTORY "${DOWNLOADS}/tools/nasm")
endif(VCPKG_HOST_IS_WINDOWS)

# For each vcpkg_find_acquire_program(NAME).cmake script,
# there must be a literal call to vcpkg_find_acquire_program(NAME)
vcpkg_list(SET variables)
macro(vcpkg_find_acquire_program NAME_AND_VAR)
    vcpkg_list(APPEND variables "${NAME_AND_VAR}")
    _vcpkg_find_acquire_program("${NAME_AND_VAR}")
endmacro()

vcpkg_find_acquire_program(BAZEL)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(GIT)
vcpkg_find_acquire_program(GN)
vcpkg_find_acquire_program(GPERF)
vcpkg_find_acquire_program(NASM)
vcpkg_find_acquire_program(NINJA)
vcpkg_find_acquire_program(PERL)
vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(SCONS)
vcpkg_find_acquire_program(YASM)

if(NOT VCPKG_HOST_IS_OSX)
    vcpkg_find_acquire_program(DOXYGEN)
    vcpkg_find_acquire_program(MESON) # System python too old (3.9; meson needs 3.10)
    vcpkg_find_acquire_program(RUBY)
    vcpkg_find_acquire_program(SWIG)
endif()

if(VCPKG_HOST_IS_LINUX)
    vcpkg_find_acquire_program(PATCHELF)
endif()

if(VCPKG_HOST_IS_WINDOWS)
    vcpkg_find_acquire_program(7Z)
    vcpkg_find_acquire_program(CLANG)
    vcpkg_find_acquire_program(DARK)
    vcpkg_find_acquire_program(GASPREPROCESSOR)
    vcpkg_find_acquire_program(GO)
    vcpkg_find_acquire_program(JOM)
    vcpkg_find_acquire_program(NUGET)
    vcpkg_find_acquire_program(PYTHON2)
endif()

list(SORT variables)
message(STATUS "Collected programs: ${variables}")

set(missing "")
foreach(variable IN LISTS variables)
    set(var_contents "${${variable}}")
    list(POP_BACK var_contents program)
    if(NOT EXISTS "${program}")
        list(APPEND missing "${variable}: ${program}")
    endif()
    list(POP_FRONT var_contents interpreter)
    if(interpreter AND NOT EXISTS "${interpreter}")
        list(APPEND missing "${variable} (interpreter): ${interpreter}")
    endif()
endforeach()
if(missing)
    list(JOIN missing "\n   " missing)
    message(FATAL_ERROR "The following programs do not exist:\n   ${missing}")
endif()

# The postcondition of `vcpkg_find_acquire_program` is that there is a regular
# variable of the requested name with a non-false value in the calling scope.
# 
# Normally, it searches for the requested program and sets a regular variable
# in the calling scope. However, it does nothing if a variable with that name
# is already set to a value which CMake regards as true.
# In contrast, `find_program` sets a cache variable when the search is run.
# It does nothing if a variable with the given name is defined with a value
# of "NOTFOUND" or ending with "-NOTFOUND".
# The small behavioral differences needs extra attention.

include("${CURRENT_HOST_INSTALLED_DIR}/share/unit-test-cmake/test-macros.cmake")

set(expected_gn "$CACHE{GN}")

# Cache variable is set to trueish value: Early return of vfap with current value.
unset(GN)
set(GN "THIS IS CACHED GN" CACHE INTERNAL "")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "THIS IS CACHED GN")

# Cache variable is NOTFOUNDish or empty value: These values evaluate to false,
# so a search via vfap should run and yield the expected path.
unset(GN)
set(GN "NOTFOUND" CACHE INTERNAL "")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "${expected_gn}")

unset(GN)
set(GN "GN-NOTFOUND" CACHE INTERNAL "")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "${expected_gn}")

unset(GN)
set(GN "" CACHE INTERNAL "")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "${expected_gn}")


# Regular variable is set to trueish value: Early return of vfap with current value.
unset(GN CACHE)
set(GN "THIS IS REGULAR GN")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "THIS IS REGULAR GN")

# Regular variable is NOTFOUNDish or empty value: These values evaluate to false,
# so a search via vfap should run and yield the expected path.
unset(GN CACHE)
set(GN "NOTFOUND")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "${expected_gn}")

unset(GN CACHE)
set(GN "GN-NOTFOUND")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "${expected_gn}")

unset(GN CACHE)
set(GN "")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "${expected_gn}")

# Regular variable is NOTFOUNDish or empty value, and it hides a cache variable:
# The cache variable takes effect.
set(GN "THIS IS CACHED GN" CACHE INTERNAL "")
set(GN "NOTFOUND")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "THIS IS CACHED GN")

set(GN "THIS IS CACHED GN" CACHE INTERNAL "")
set(GN "GN-NOTFOUND")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "THIS IS CACHED GN")

set(GN "THIS IS CACHED GN" CACHE INTERNAL "")
set(GN "")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "THIS IS CACHED GN")

set(GN "NOTFOUND" CACHE INTERNAL "")
set(GN "NOTFOUND")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "${expected_gn}")

set(GN "CACHED-NOTFOUND" CACHE INTERNAL "")
set(GN "NOTFOUND")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "${expected_gn}")

set(GN "" CACHE INTERNAL "")
set(GN "NOTFOUND")
unit_test_check_variable_equal([[_vcpkg_find_acquire_program(GN)]] GN "${expected_gn}")

# If vfap cannot find or acquire the requested program, it raises a fatal error.
unit_test_ensure_fatal_error([[_vcpkg_find_acquire_program(REALLY_NO_SUCH_PROGAM)]])

