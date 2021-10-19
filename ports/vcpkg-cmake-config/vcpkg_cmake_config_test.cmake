#[===[.md:
# vcpkg_cmake_config_test

Automatically test the correctness of the configuration file exported by cmake

## Usage
```cmake
vcpkg_cmake_config_test(
    [target_name <PORT_NAME>]
    [TARGET_VARS <TARGETS>...]
    [HEADERS <headername.h>...]
    [FUNCTIONS <function1> ...]
)
```

## Parameters
### target_name
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

macro(z_get_cmake_targets)
    set(target_names )
    set(target_folders )
    
    file(GLOB_RECURSE cmake_files "${CURRENT_PACKAGES_DIR}/*/*.cmake")
    foreach(cmake_file IN ITEMS cmake_files)
        get_filename_component(target_folder ${cmake_file} DIRECTORY)
        get_filename_component(target_folder ${target_folder} NAME)
        vcpkg_list(APPEND target_folders "${target_folder}")
        file(READ "${cmake_file}" CMAKE_CONTENT)
        string(REGEX MATCH "add_library.([^\ ]+)\ " target_name "${CMAKE_CONTENT}")
        string(REPLACE "add_library(" "" target_name "${target_name}")
        string(REPLACE " " "" target_name "${target_name}")
        if (NOT target_name)
            continue()
        endif()
        list(APPEND target_names ${target_name})
        debug_message("target_name: ${target_name}")
    endforeach()
    unset(target_name)
    vcpkg_list(REMOVE_DUPLICATES target_names)
    vcpkg_list(REMOVE_DUPLICATES target_folders)
    
    list(LENGTH target_names target_size)
    list(LENGTH target_folders folder_size)
    
    if (target_size EQUAL 0 OR folder_size EQUAL 0)
        return()
    endif()
    
    if (NOT folder_size EQUAL 1 AND NOT arg_TARGET_NAME)
        message(FATAL_ERROR "More than one folder contains cmake configuration files, please set \"target_name\" to select the certain target name")
    endif()
    
    #set(target_names ${target_names} PARENT_SCOPE)
    #set(target_folder ${target_folders} PARENT_SCOPE)
endmacro()

macro(z_write_sample_code current_target)
    set(test_dir "${CURRENT_BUILDTREES_DIR}/test_cmake")
    file(REMOVE_RECURSE "${test_dir}")
    file(MAKE_DIRECTORY "${test_dir}")
    
    # c/cxx test file
    if (EXISTS "${CURRENT_PORT_DIR}/vcpkg_test.c")
        set(test_source cmake_test.c)
        configure_file("${CURRENT_PORT_DIR}/vcpkg_test.c" "${test_dir}/cmake_test.c" COPYONLY)
    elseif (EXISTS "${CURRENT_PORT_DIR}/vcpkg_test.cpp")
        set(test_source cmake_test.cpp)
        configure_file("${CURRENT_PORT_DIR}/vcpkg_test.c" "${test_dir}/cmake_test.cpp" COPYONLY)
    else()
        set(src_content
[[
#include <stdio.h>
@extern_header_checks@
@extern_symbol_checks_base@
int main(void)
{@extern_symbol_check_symbol@}
]]
        )

        file(WRITE "${test_dir}/cmake_test.cpp.in" "${src_content}")
        configure_file("${test_dir}/cmake_test.cpp.in" "${test_dir}/cmake_test.cpp" @ONLY)
        set(test_source cmake_test.cpp)
    endif()
    
    # CMakeLists.txt
    if (EXISTS "${CURRENT_PORT_DIR}/vcpkg_test.cmake")
        configure_file("${CURRENT_PORT_DIR}/vcpkg_test.cmake" "${test_dir}/CMakeLists.txt" COPYONLY)
    else()
        set(CMAKE_LISTS_CONTENT
[[
cmake_minimum_required (VERSION 3.19)
project (cmake_test)

find_package(@target_folder@ CONFIG REQUIRED)

add_executable(cmake_test @test_source@)

target_link_libraries(cmake_test PRIVATE @current_target@)
]]
    )
    
        set(current_target ${current_target})
        file(WRITE "${test_dir}/CMakeLists.txt.in" "${CMAKE_LISTS_CONTENT}")
        configure_file("${test_dir}/CMakeLists.txt.in" "${test_dir}/CMakeLists.txt" @ONLY)
    endif()
endmacro()

macro(build_with_toolchain)
    foreach(build_type IN ITEMS "Debug" "Release")
        set(config_cmd ${CMAKE_COMMAND} -G Ninja
            -DCMAKE_BUILD_TYPE=${build_type}
            -DCMAKE_PREFIX_PATH="${CURRENT_PACKAGES_DIR}/share/${target_folder}"
            -DCMAKE_SOURCE_DIR="${test_dir}"
            -DCMAKE_BINARY_DIR="${test_dir}"
            -DCMAKE_TOOLCHAIN_FILE="${VCPKG_ROOT_DIR}/scripts/buildsystems/vcpkg.cmake"
            -DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}
        )
        set(build_cmd "${CMAKE_COMMAND} --build . --config ${build_type} -- -v")
        
        execute_process(
            COMMAND "${config_cmd}"
            WORKING_DIRECTORY "${test_dir}"
            RESULT_VARIABLE error_code
            OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/config-test-cmake-out.log"
            ERROR_FILE "${CURRENT_BUILDTREES_DIR}/config-test-cmake-err.log"
        )
        
        if (error_code)
            message(FATAL_ERROR
                "Test cmake configuration failed, please check cmake configuration file!"
                "See log: ${CURRENT_BUILDTREES_DIR}/config-test-cmake-err.log"
            )
        endif()
        
        execute_process(
            COMMAND "${build_cmd}"
            WORKING_DIRECTORY "${test_dir}"
            RESULT_VARIABLE error_code
            OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/build-test-cmake-out.log"
            ERROR_FILE "${CURRENT_BUILDTREES_DIR}/build-test-cmake-err.log"
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
    
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "TARGET_NAME" "TARGET_VARS;HEADERS;FUNCTIONS")
    # First, we should get the cmake targets automanticlly
    if ((arg_TARGET_NAME AND NOT arg_TARGET_VARS) OR (NOT arg_TARGET_NAME AND arg_TARGET_VARS))
        message(FATAL_ERROR "TARGET_NAME and TARGET_VARS must be declared at same time!")
    endif()
    
    if (NOT arg_TARGET_NAME)
        z_get_cmake_targets()
    endif()
    
    if (arg_TARGET_NAME)
        set(target_folder "${arg_TARGET_NAME}")
        set(target_names ${arg_TARGET_VARS})
    elseif (NOT target_folder OR NOT target_names)
        # Skip cmake test because the cmake configuration is not exported
        message(STATUS "Could not find the cmake configuration file, skip test the cmake configuration.")
        return()
    endif()
    
    
    set(extern_header_checks )
    set(extern_symbol_checks_base )
    set(extern_symbol_check_symbol )
    if (arg_HEADERS)
        foreach(header IN LISTS arg_HEADERS)
            string(APPEND extern_header_checks ${extern_header_checks} "#include <${header}>\n")
        endforeach()
    endif()
    
    if (arg_FUNCTIONS)
        set(extern_symbol_checks_base "typedef int (*symbol_func)(void);\n\n")
        foreach(symbol ${arg_FUNCTIONS})
            set(extern_symbol_check_symbol "symbol_func func = (symbol_func)&${symbol};\nreturn func();\n")
        endforeach()
    endif()
    
    foreach(target_name IN LISTS target_names)
        # Write a sample CMakeLists.txt and source file
        z_write_sample_code(${target_name})
        # Build
        build_with_toolchain()
    endforeach()
    unset(extern_symbol_check_symbol)
    unset(extern_symbol_checks_base)
    unset(extern_header_checks)
endfunction()
