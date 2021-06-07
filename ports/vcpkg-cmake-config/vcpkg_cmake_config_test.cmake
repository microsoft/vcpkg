#[===[.md:
# vcpkg_cmake_config_test

Automatically test the correctness of the configuration file exported by cmake

## Usage
```cmake
vcpkg_cmake_config_test(
    [TARGET_NAME <PORT_NAME>]
    [TARGET_VARS <TARGETS>...]
    [HEADERS <headername.h>...]
    [FUNCTIONS <function1> ...]
)
```

## Parameters
### TARGET_NAME
Specify the main parameters to find the port through find_package
The default value is the prefix of -config.cmake/Config.cmake/Targets.cmake/-targets.cmake

### TARGET_VARS
Specify targets in the configuration file, the value may contain namespace

### HEADERS
Specify the installed header file names (including the relative path)

### FUNCTIONS
Specify the exported function names, do not support namespace currently

## Notes
This function allows to use `vcpkg_test.cmake` / `vcpkg_test.c` / `vcpkg_test.cpp`
that exists in PORT_DIR to test the generated cmake file.
Still work in progress. If there are more cases which can be handled here feel free to add them.

## Examples

* [ptex](https://github.com/Microsoft/vcpkg/blob/master/ports/ptex/portfile.cmake)
#]===]

macro(get_cmake_targets)
    set(TARGET_NAMES )
    set(TARGET_FOLDERS )
    
    file(GLOB_RECURSE CMAKE_FILES ${CURRENT_PACKAGES_DIR}/*/*.cmake)
    foreach(CMAKE_FILE ${CMAKE_FILES})
        get_filename_component(TARGET_FOLDER ${CMAKE_FILE} DIRECTORY)
        get_filename_component(TARGET_FOLDER ${TARGET_FOLDER} NAME)
        list(APPEND TARGET_FOLDERS ${TARGET_FOLDER})
        file(READ ${CMAKE_FILE} CMAKE_CONTENT)
        string(REGEX MATCH "add_library.([^\ ]+)\ " TARGET_NAME "${CMAKE_CONTENT}")
        string(REPLACE "add_library(" "" TARGET_NAME "${TARGET_NAME}")
        string(REPLACE " " "" TARGET_NAME "${TARGET_NAME}")
        if (NOT TARGET_NAME)
            continue()
        endif()
        list(APPEND TARGET_NAMES ${TARGET_NAME})
        debug_message("TARGET_NAME: ${TARGET_NAME}")
    endforeach()
    unset(TARGET_NAME)
    list(REMOVE_DUPLICATES TARGET_NAMES)
    list(REMOVE_DUPLICATES TARGET_FOLDERS)
    
    list(LENGTH TARGET_NAMES TARGET_SIZE)
    list(LENGTH TARGET_FOLDERS FOLDER_SIZE)
    
    if (TARGET_SIZE EQUAL 0 OR FOLDER_SIZE EQUAL 0)
        return()
    endif()
    
    if (NOT FOLDER_SIZE EQUAL 1 AND NOT _tcc_TARGET_NAME)
        message(FATAL_ERROR "More than one folder contains cmake configuration files, please set \"TARGET_NAME\" to select the certain target name")
    endif()
    
    set(TARGET_NAMES ${TARGET_NAMES} PARENT_SCOPE)
    set(TARGET_FOLDER ${TARGET_FOLDERS} PARENT_SCOPE)
endmacro()

macro(write_sample_code CURRENT_TARGET)
    set(TEST_DIR ${CURRENT_BUILDTREES_DIR}/test_cmake)
    file(REMOVE_RECURSE ${TEST_DIR})
    file(MAKE_DIRECTORY ${TEST_DIR})
    
    # c/cxx test file
    if (EXISTS ${CURRENT_PORT_DIR}/vcpkg_test.c)
        set(TEST_SOURCE cmake_test.c)
        configure_file(${CURRENT_PORT_DIR}/vcpkg_test.c ${TEST_DIR}/cmake_test.c COPYONLY)
    elseif (EXISTS ${CURRENT_PORT_DIR}/vcpkg_test.cpp)
        set(TEST_SOURCE cmake_test.cpp)
        configure_file(${CURRENT_PORT_DIR}/vcpkg_test.c ${TEST_DIR}/cmake_test.cpp COPYONLY)
    else()
        set(SRC_CONTENT
[[
#include <stdio.h>
@EXTERN_HEADER_CHECKS@
@EXTERN_SYMBOL_CHECKS_BASE@
int main(void)
{@EXTERN_SYMBOL_CHECK_SYMBOL@}
]]
        )

        file(WRITE ${TEST_DIR}/cmake_test.cpp.in ${SRC_CONTENT})
        configure_file(${TEST_DIR}/cmake_test.cpp.in ${TEST_DIR}/cmake_test.cpp @ONLY)
        set(TEST_SOURCE cmake_test.cpp)
    endif()
    
    # CMakeLists.txt
    if (EXISTS ${CURRENT_PORT_DIR}/vcpkg_test.cmake)
        configure_file(${CURRENT_PORT_DIR}/vcpkg_test.cmake ${TEST_DIR}/CMakeLists.txt COPYONLY)
    else()
        set(CMAKE_LISTS_CONTENT
[[
cmake_minimum_required (VERSION 3.19)
project (cmake_test)

find_package(@TARGET_FOLDER@ CONFIG REQUIRED)

add_executable(cmake_test @TEST_SOURCE@)

target_link_libraries(cmake_test PRIVATE @CURRENT_TARGET@)
]]
    )
    
        set(CURRENT_TARGET ${CURRENT_TARGET})
        file(WRITE ${TEST_DIR}/CMakeLists.txt.in ${CMAKE_LISTS_CONTENT})
        configure_file(${TEST_DIR}/CMakeLists.txt.in ${TEST_DIR}/CMakeLists.txt @ONLY)
    endif()
endmacro()

macro(build_with_toolchain)
    foreach(BUILD_TYPE Debug Release)
        set(CONFIG_CMD ${CMAKE_COMMAND} -G Ninja
            -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
            -DCMAKE_PREFIX_PATH=${CURRENT_PACKAGES_DIR}/share/${TARGET_FOLDER}
            -DCMAKE_SOURCE_DIR=${TEST_DIR}
            -DCMAKE_BINARY_DIR=${TEST_DIR}
            -DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT_DIR}/scripts/buildsystems/vcpkg.cmake
            -DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}
        )
        set(BUILD_CMD ${CMAKE_COMMAND} --build . --config ${BUILD_TYPE} -- -v)
        
        execute_process(
            COMMAND ${CONFIG_CMD}
            WORKING_DIRECTORY ${TEST_DIR}
            RESULT_VARIABLE error_code
            OUTPUT_FILE ${CURRENT_BUILDTREES_DIR}/config-test-cmake-out.log
            ERROR_FILE ${CURRENT_BUILDTREES_DIR}/config-test-cmake-err.log
        )
        
        if (error_code)
            message(FATAL_ERROR
                "Test cmake configuration failed, please check cmake configuration file!"
                "See log: ${CURRENT_BUILDTREES_DIR}/config-test-cmake-err.log"
            )
        endif()
        
        execute_process(
            COMMAND ${BUILD_CMD}
            WORKING_DIRECTORY ${TEST_DIR}
            RESULT_VARIABLE error_code
            OUTPUT_FILE ${CURRENT_BUILDTREES_DIR}/build-test-cmake-out.log
            ERROR_FILE ${CURRENT_BUILDTREES_DIR}/build-test-cmake-err.log
        )
        
        if (error_code)
            message(FATAL_ERROR
                "Test cmake configuration failed, please check cmake configuration file!"
                "See log: ${CURRENT_BUILDTREES_DIR}/config-test-cmake-err.log"
            )
        endif()
    endforeach()
endmacro()

function(vcpkg_cmake_config_test)
    if (NOT _VCPKG_EDITABLE)
        # Skip cmake test
        return()
    endif()
    
    cmake_parse_arguments(PARSE_ARGV 0 _tcc "" "TARGET_NAME" "TARGET_VARS;HEADERS;FUNCTIONS")
    # First, we should get the cmake targets automanticlly
    if ((_tcc_TARGET_NAME AND NOT TARGET_VARS) OR (NOT TARGET_NAME AND TARGET_VARS))
        message(FATAL_ERROR "TARGET_NAME and TARGET_VARS must be declared at same time!")
    endif()
    
    if (NOT _tcc_TARGET_NAME)
        get_cmake_targets()
    endif()
    
    if (_tcc_TARGET_NAME)
        set(TARGET_FOLDER ${_tcc_TARGET_NAME})
        set(TARGET_NAMES ${_tcc_TARGET_VARS})
    elseif (NOT TARGET_FOLDER OR NOT TARGET_NAMES)
        # Skip cmake test because the cmake configuration is not exported
        message(STATUS "Could not find the cmake configuration file, skip test the cmake configuration.")
        return()
    endif()
    
    
    set(EXTERN_HEADER_CHECKS )
    set(EXTERN_SYMBOL_CHECKS_BASE )
    set(EXTERN_SYMBOL_CHECK_SYMBOL )
    if (_tcc_HEADERS)
        foreach(header ${_tcc_HEADERS})
            string(APPEND EXTERN_HEADER_CHECKS ${EXTERN_HEADER_CHECKS} "#include <${header}>\n")
        endforeach()
    endif()
    
    if (_tcc_FUNCTIONS)
        set(EXTERN_SYMBOL_CHECKS_BASE "typedef int (*symbol_func)(void);\n\n")
        foreach(symbol ${_tcc_FUNCTIONS})
            set(EXTERN_SYMBOL_CHECK_SYMBOL "symbol_func func = (symbol_func)&${symbol};\nreturn func();\n")
        endforeach()
    endif()
    
    foreach(TARGET_NAME ${TARGET_NAMES})
        # Write a sample CMakeLists.txt and source file
        write_sample_code(${TARGET_NAME})
        # Build
        build_with_toolchain()
    endforeach()
    unset(EXTERN_SYMBOL_CHECK_SYMBOL)
    unset(EXTERN_SYMBOL_CHECKS_BASE)
    unset(EXTERN_HEADER_CHECKS)
endfunction()
