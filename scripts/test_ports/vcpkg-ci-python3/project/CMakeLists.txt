cmake_minimum_required(VERSION 3.12)
project(python3-test)

set(Python_ARTIFACTS_PREFIX "_MEOW")

# We need to opt-out of CMP0148 to be able to test the pre-CMake 3.12 Python
# find modules. The old policy is deprecated, so, at some point, this aspect
# of the test will have to go away.
if(POLICY CMP0148)
    cmake_policy(SET CMP0148 OLD)
endif()

# The purpose of this test is to ensure that we get the expected values
# from the finders, not crosscompiling. So, let's not even go there.
# These find_package() calls aren't required because FindPythonInterp
# seems to not return a result in CI. Probably because FindPythonInterp
# prefers the system Python instead of the executable from the python3
# port.
if(NOT CMAKE_CROSSCOMPILING)
    find_package(PythonInterp)
endif()
find_package(PythonLibs)

# The old find modules should NOT be prefixed.
if(DEFINED PythonInterp_MEOW_FOUND OR DEFINED PYTHON_MEOW_EXECUTABLE)
    message(FATAL_ERROR "FindPythonInterp prefixed the result variables")
endif()
if(DEFINED PythonLibs_MEOW_FOUND OR DEFINED PYTHON_MEOW_LIBRARIES)
    message(FATAL_ERROR "FindPythonLibs prefixed the result variables")
endif()

function(test_result NAME TYPE EXPECTED UNEXPECTED)
    if(NOT ${TYPE} ${EXPECTED}${NAME})
        message(FATAL_ERROR "${EXPECTED}${NAME} should be ${TYPE}")
    endif()
    if(${TYPE} ${UNEXPECTED}${NAME})
        message(FATAL_ERROR "${UNEXPECTED}${NAME} should not be ${TYPE}")
    endif()
endfunction()

function(test_new_finder EXPECTED UNEXPECTED)
    test_result(::Python TARGET ${EXPECTED} ${UNEXPECTED})
    test_result(_LIBRARIES DEFINED ${EXPECTED} ${UNEXPECTED})

    if(NOT CMAKE_CROSSCOMPILING)
        test_result(_EXECUTABLE DEFINED ${EXPECTED} ${UNEXPECTED})
        test_result(_STDLIB DEFINED ${EXPECTED} ${UNEXPECTED})
        test_result(::Interpreter TARGET ${EXPECTED} ${UNEXPECTED})
    endif()
endfunction()

if(NOT CMAKE_CROSSCOMPILING)
    set(_INTERPRETER "Interpreter")
endif()

# The new find modules should be prefixed if CMake is 4.0+
find_package(Python REQUIRED COMPONENTS ${_INTERPRETER} Development)
if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.0)
    set(EXPECTED_PYTHON Python_MEOW)
    set(UNEXPECTED_PYTHON Python)
else()
    set(EXPECTED_PYTHON Python)
    set(UNEXPECTED_PYTHON Python_MEOW)
endif()
test_new_finder(${EXPECTED_PYTHON} ${UNEXPECTED_PYTHON})

# Also test non-prefixed. Use Python3:: to avoid conflicts with Python_MEOW::
# The test against Python3_MEOW should never happen because the prefix variable
# should be Python3_ARTIFACT_PREFIX, but we set Python_ARTIFACT_PREFIX.
find_package(Python3 REQUIRED COMPONENTS ${_INTERPRETER} Development)
test_new_finder(Python3 Python3_MEOW)

# Test embedding the libraries found.
function(add_test_executable TARGET LIBRARIES INCLUDES)
    add_executable(${TARGET} main.c)
    target_link_libraries(${TARGET} PRIVATE ${LIBRARIES})
    if(INCLUDES)
        target_include_directories(${TARGET} PRIVATE ${INCLUDES})
    endif()
endfunction()

# We're purposefully not testing the result of the old finders.
# The python3 port never added a vcpkg-cmake-wrapper for FindPythonLibs,
# and it seems like a poor use of time to do so at this point - the
# old finders are soft removed as of CMake 3.27.
add_test_executable(new_with_prefix "${EXPECTED_PYTHON}::Python" "")
add_test_executable(new_without_prefix "${Python3_LIBRARIES}" "${Python3_INCLUDE_DIRS}")
