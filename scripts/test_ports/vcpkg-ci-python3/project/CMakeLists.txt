cmake_minimum_required(VERSION 3.12)

# We need to opt-out of CMP0148 to be able to test the pre-CMake 3.12 Python
# find modules. The old policy is deprecated, so, at some point, this aspect
# of the test will have to go away.
# This must appear before `project` to affect vcpkg.cmake's find_package macro.
if(POLICY CMP0148)
    cmake_policy(SET CMP0148 OLD)
endif()

project(python3-test)

# Options for matching library vs. build type
set(EXPECTED_LIBRARY_KEYWORD "not set" CACHE STRING "debug or optimized")
set(EXPECTED_LIBRARY_PREFIX  "not set" CACHE STRING "link library dir for current build type")

# A goal of this test project is to ensure that we get the expected values
# from the modern find modules with regard to Python[3]_ARTIFACTS_PREFIX.
set(Python_ARTIFACTS_PREFIX "_MEOW")
set(Python3_ARTIFACTS_PREFIX "")

if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.0 AND DEFINED Python_EXECUTABLE AND NOT DEFINED Python_MEOW_EXECUTABLE)
    set(Python_MEOW_EXECUTABLE "${Python_EXECUTABLE}")
    unset(Python_EXECUTABLE CACHE)
endif()


# Test helpers

function(assert condition)
    string(CONFIGURE "@condition@" condition_quoted @ONLY ESCAPE_QUOTES)
    cmake_language(EVAL CODE "
        if(${condition_quoted})
            # good
        else()
            message(SEND_ERROR \"Assertion failed: ${condition_quoted}\")
        endif()
    ")
endfunction()

function(check_find_python_results)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "EXPECTED;UNEXPECTED" "")

    assert("TARGET ${arg_EXPECTED}::Python")
    assert("NOT TARGET ${arg_UNEXPECTED}::Python")
    assert("${arg_EXPECTED}_LIBRARIES")
    assert("NOT ${arg_UNEXPECTED}_LIBRARIES")

    string(FIND "${EXPECTED_LIBRARY_KEYWORD};${${arg_EXPECTED}_LIBRARIES}" "${EXPECTED_LIBRARY_KEYWORD};${EXPECTED_LIBRARY_PREFIX}" prefix_index)
    if("${prefix_index}" EQUAL "-1")
        message(SEND_ERROR 
            "Actual ${arg_EXPECTED} libraries: ${${arg_EXPECTED}_LIBRARIES}\n"
            "Expected ${CMAKE_BUILD_TYPE} location: ${EXPECTED_LIBRARY_PREFIX}"
        )
    endif()

    assert("${arg_EXPECTED}_EXECUTABLE")
    assert("NOT ${arg_UNEXPECTED}_EXECUTABLE")
    assert("${arg_EXPECTED}_STDLIB")
    assert("NOT ${arg_UNEXPECTED}_STDLIB")
    assert("TARGET ${arg_EXPECTED}::Interpreter")
    assert("NOT TARGET ${arg_UNEXPECTED}::Interpreter")
endfunction()


### Testing the deprecated FindPythonLibs and FindPythonInterpreter modules

# Intentionally not testing success or the *expected* result:
# The python3 port never added a vcpkg-cmake-wrapper for FindPythonLibs,
# and these find modules are deprecated now.

find_package(PythonLibs)
if(DEFINED PythonLibs_MEOW_FOUND OR DEFINED PYTHON_MEOW_LIBRARIES)
    message(FATAL_ERROR "FindPythonLibs unexpectedly prefixed the result variables")
endif()

if(NOT CMAKE_CROSSCOMPILING)
    find_package(PythonInterp)
    if(DEFINED PythonInterp_MEOW_FOUND OR DEFINED PYTHON_MEOW_EXECUTABLE)
        message(FATAL_ERROR "FindPythonInterp unexpectedly prefixed the result variables")
    endif()
endif()


### Testing the FindPython module (artifact prefix: _MEOW)

add_executable(main-python-target main.c)

find_package(Python REQUIRED COMPONENTS Interpreter Development)

if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.0)
    # With CMake is 4.0+, the find module outputs should use the prefix.
    check_find_python_results(EXPECTED Python_MEOW UNEXPECTED Python)
    target_link_libraries(main-python-target PRIVATE Python_MEOW::Python)
    set(libraries_to_check "${Python_MEOW_LIBRARIES}")
else()
    check_find_python_results(EXPECTED Python UNEXPECTED Python_MEOW)
    target_link_libraries(main-python-target PRIVATE Python::Python)
    set(libraries_to_check "${Python_LIBRARIES}")
endif()


### Testing the FindPython3 module (artifact prefix: empty)

add_executable(main-python3-libraries main.c)

find_package(Python3 REQUIRED COMPONENTS Interpreter Development)
check_find_python_results(EXPECTED Python3 UNEXPECTED Python3_MEOW)

target_include_directories(main-python3-libraries PRIVATE ${Python3_INCLUDE_DIRS})
target_link_libraries(main-python3-libraries PRIVATE ${Python3_LIBRARIES})
