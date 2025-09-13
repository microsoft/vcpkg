cmake_minimum_required(VERSION 4.0)
project(python3-test)

set(Python_ARTIFACTS_PREFIX "_MEOW")

# We need to opt-out of CMP0148 to be able to test the pre-CMake 3.12 Python
# find modules. The old policy is deprecated, so, at some point, this aspect
# of the test will have to go away.
cmake_policy(SET CMP0148 OLD)

# This is the "wrong" order for using the old find modules,
# but we need to do it this way to ensure that we get the host
# python3 and the target libs. If we call FindPythonInterp first,
# CMake will make the libraries match the interpreter.
find_package(PythonLibs REQUIRED)
find_package(PythonInterp REQUIRED)

# The old find modules should NOT be prefixed.
if(DEFINED PYTHON_MEOW_LIBRARIES OR DEFINED PYTHON_MEOW_EXECUTABLE)
    message(FATAL_ERROR "Old find module prefixed the result variables")
endif()

# The old find modules do not return the path to the Python standard
# library, so we will need to fetch that ourselves.
execute_process(
    COMMAND ${PYTHON_EXECUTABLE}
    -c "import sysconfig; print(sysconfig.get_path('stdlib'))"
    OUTPUT_VARIABLE PYTHON_STDLIB
)
string(STRIP "${PYTHON_STDLIB}" PYTHON_STDLIB)

# The new find modules should be prefixed.
find_package(Python REQUIRED COMPONENTS Interpreter Development)
if(DEFINED Python_EXECUTABLE OR DEFINED Python_LIBRARIES OR TARGET Python::Python)
    message(FATAL_ERROR "New find modules unexpectedly set unprefixed result variables")
elseif(NOT DEFINED Python_MEOW_EXECUTABLE OR NOT DEFINED Python_MEOW_LIBRARIES OR NOT TARGET Python_MEOW::Python)
    message(FATAL_ERROR "New find modules didn't set prefixed result variables")
endif()

# Also test non-prefixed. Use Python3:: to avoid conflicts with Python_MEOW::
# The test against Python3_MEOW should never happen because the prefix variable
# should be Python3_ARTIFACT_PREFIX, but we set Python_ARTIFACT_PREFIX.
unset(Python_ARTIFACTS_PREFIX)
find_package(Python3 REQUIRED COMPONENTS Interpreter Development)
if(NOT DEFINED Python3_EXECUTABLE OR NOT DEFINED Python3_LIBRARIES OR NOT TARGET Python3::Python)
    message(FATAL_ERROR "New find modules didn't set unprefixed result variables")
elseif(DEFINED Python3_MEOW_EXECUTABLE OR DEFINED Python3_MEOW_LIBRARIES OR TARGET Python3_MEOW::Python)
    message(FATAL_ERROR "New find modules unexpectedly set prefixed result variables")
endif()

# Test embedding the returned libraries.
set(_NAMES old new_with_prefix new_without_prefix)
set(_STDLIBS "${PYTHON_STDLIB}" "${Python_MEOW_STDLIB}" "${Python3_STDLIB}")
set(_PYLIBS "${PYTHON_LIBRARIES}" Python_MEOW::Python "${Python3_LIBRARIES}")
set(_INCLUDES "${PYTHON_INCLUDE_DIRS}" "" "${Python3_INCLUDE_DIRS}")
foreach(i IN ZIP_LISTS _NAMES _PYLIBS _INCLUDES _STDLIBS)
    add_executable(${i_0} main.c)
    target_link_libraries(${i_0} PRIVATE ${i_1})
    if(i_2)
        target_include_directories(${i_0} PRIVATE ${i_2})
    endif()
    file(TO_CMAKE_PATH "${i_3}" _STDLIB)
    target_compile_definitions(${i_0} PRIVATE "-DBATTERIES=L\"${_STDLIB}\"")
endforeach()
