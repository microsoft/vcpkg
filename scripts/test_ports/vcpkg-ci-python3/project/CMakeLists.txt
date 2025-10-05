cmake_minimum_required(VERSION 3.12)

# We need to opt-out of CMP0148 to be able to test the pre-CMake 3.12 Python
# find modules. The old policy is deprecated, so, at some point, this aspect
# of the test will have to go away.
# This must appear before `project` to affect vcpkg.cmake's find_package macro.
if(POLICY CMP0148)
    cmake_policy(SET CMP0148 OLD)
endif()

project(python3-test)

# A goal of this test project is to ensure that we get the expected values
# from the modern find modules with regard to Python[3]_ARTIFACTS_PREFIX.
set(Python_ARTIFACTS_PREFIX "_MEOW")
set(Python3_ARTIFACTS_PREFIX "")

# This test doesn't setup an interpreter.
set(MAYBE_INTERPRETER "")
if(NOT CMAKE_CROSSCOMPILING)
    set(MAYBE_INTERPRETER "Interpreter")
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

    if(NOT CMAKE_CROSSCOMPILING)
        assert("${arg_EXPECTED}_EXECUTABLE")
        assert("NOT ${arg_UNEXPECTED}_EXECUTABLE")
        assert("${arg_EXPECTED}_STDLIB")
        assert("NOT ${arg_UNEXPECTED}_STDLIB")
        assert("TARGET ${arg_EXPECTED}::Interpreter")
        assert("NOT TARGET ${arg_UNEXPECTED}::Interpreter")
    endif()
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

find_package(Python REQUIRED COMPONENTS ${MAYBE_INTERPRETER} Development)

if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.0)
    # With CMake is 4.0+, the find module outputs should use the prefix.
    check_find_python_results(EXPECTED Python_MEOW UNEXPECTED Python)
    target_link_libraries(main-python-target PRIVATE Python_MEOW::Python)
else()
    check_find_python_results(EXPECTED Python UNEXPECTED Python_MEOW)
    target_link_libraries(main-python-target PRIVATE Python::Python)
endif()


### Testing the FindPython3 module (artifact prefix: empty)

add_executable(main-python3-libraries main.c)

find_package(Python3 REQUIRED COMPONENTS ${MAYBE_INTERPRETER} Development)
check_find_python_results(EXPECTED Python3 UNEXPECTED Python3_MEOW)

target_include_directories(main-python3-libraries PRIVATE ${Python3_INCLUDE_DIRS})
target_link_libraries(main-python3-libraries PRIVATE ${Python3_LIBRARIES})
