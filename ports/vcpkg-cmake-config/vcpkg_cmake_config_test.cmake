#[===[.md:
# vcpkg_cmake_config_test

Automatically test the correctness of the configuration file exported by cmake

```cmake
vcpkg_cmake_config_test(
    [USAGE <FIND_METHOD>]
    [TARGET_NAMES <TARGETS>...]
    [HEADERS <headername.h>...]
    [FUNCTIONS <function1> ...]
)
```

For most ports, `vcpkg_cmake_config_test` should work without passing any options,
`vcpkg_cmake_config_test` will automatically detect the targets declared in the generated
cmake configuration file which are used in `find_package`, and set the targets to `USAGE`.

`TARGET_NAMES` should use the target name in `target_link_libraries` and support namespace.

For more advanced usage, `vcpkg_cmake_config_test` supports the use of reserved c/c++ code for testing.
Please encapsulate the test code as one or more functions and save them to `vcpkg_test.c` or `vcpkg_test.cpp`,
and pass the name of the system header file that needs to be included into the `HEADERS`.

And, please use option `FUNCTIONS` to pass these test function names into `vcpkg_cmake_config_test`.

More, you can implement the test cmake code by yourself to add additional compilation options
or cmake options by writing them into `vcpkg_test.cmake`.

Please note that `vcpkg_test.cmake` / `vcpkg_test.c` / `vcpkg_test.cpp` must be placed in the same directory
as `portfile.cmake`.

## Examples

* [curl](https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake)
* [ptex](https://github.com/Microsoft/vcpkg/blob/master/ports/ptex/portfile.cmake)
#]===]

macro(z_get_cmake_targets)
    set(target_names )
    set(target_folders )

    file(GLOB_RECURSE cmake_files "${CURRENT_PACKAGES_DIR}/*/*.cmake")
    foreach(cmake_file IN LISTS cmake_files)
        get_filename_component(target_folder ${cmake_file} DIRECTORY)
        get_filename_component(target_folder_name ${target_folder} NAME)
        if (cmake_file MATCHES "[Cc]onfig\.cmake")
            vcpkg_list(APPEND target_folders "${target_folder_name}")
        endif()
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
        message(WARANING "Found the following cmake configuration file but not found the target.")
        return()
    endif()

    if (NOT folder_size EQUAL 1 AND NOT arg_USAGE)
        message(FATAL_ERROR "More than one folder contains cmake configuration files, please set \"TARGET_NAMES\" to select the certain target name")
    endif()

    set(target_names ${target_names})
    set(target_folder ${target_folders})
    set(target_usage ${target_folder} CONFIG)
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

find_package(@target_usage@ REQUIRED)

add_executable(cmake_test @test_source@)

target_link_libraries(cmake_test PRIVATE @current_target@)
]]
    )

        set(current_target ${current_target})
        file(WRITE "${test_dir}/CMakeLists.txt.in" "${CMAKE_LISTS_CONTENT}")
        configure_file("${test_dir}/CMakeLists.txt.in" "${test_dir}/CMakeLists.txt" @ONLY)
    endif()
endmacro()

macro(z_build_with_toolchain)
    foreach(build_type IN ITEMS "Debug" "Release")
        unset(config_cmd)
        unset(build_cmd)
        string(TOLOWER ${build_type} build_type_lower)

        vcpkg_list(APPEND config_cmd
            "${CMAKE_COMMAND}"
            -G
            Ninja
            -DCMAKE_BUILD_TYPE=${build_type}
            "-DCMAKE_PREFIX_PATH=${CURRENT_PACKAGES_DIR}/share/${target_folder}"
            -DCMAKE_SOURCE_DIR="${test_dir}"
            -DCMAKE_BINARY_DIR="${test_dir}"
            "-DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT_DIR}/scripts/buildsystems/vcpkg.cmake"
            -DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}
            "-D${target_folders}_DIR=${CURRENT_PACKAGES_DIR}/share/${target_folder}"
                   
        )
        vcpkg_list(APPEND build_cmd
            "${CMAKE_COMMAND}"
            --build
            .
            --config
            ${build_type}
            --
            -v
        )

        debug_message("command: ${config_cmd}")
        execute_process(
            COMMAND ${config_cmd}
            WORKING_DIRECTORY "${test_dir}"
            RESULT_VARIABLE error_code
            OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/config-test-cmake-${build_type_lower}-out.log"
            ERROR_FILE  "${CURRENT_BUILDTREES_DIR}/config-test-cmake-${build_type_lower}-err.log"
        )

        if (error_code)
            message(FATAL_ERROR
                "  Test cmake configuration failed, please check cmake configuration file!\n"
                "  Error code: ${error_code}\n"
                "  See logs for more information:\n"
                "      ${CURRENT_BUILDTREES_DIR}/config-test-cmake-${build_type_lower}-out.log\n"
                "      ${CURRENT_BUILDTREES_DIR}/config-test-cmake-${build_type_lower}-err.log\n"
            )
        endif()

        debug_message("command: ${build_cmd}")
        execute_process(
            COMMAND ${build_cmd}
            WORKING_DIRECTORY "${test_dir}"
            RESULT_VARIABLE error_code
            OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/build-test-cmake-${build_type_lower}-out.log"
            ERROR_FILE  "${CURRENT_BUILDTREES_DIR}/build-test-cmake-${build_type_lower}-err.log"
        )

        if (error_code)
            message(FATAL_ERROR
                "  Test cmake configuration failed, please check cmake configuration file!\n"
                "  Error code: ${error_code}\n"
                "  See logs for more information:\n"
                "      ${CURRENT_BUILDTREES_DIR}/build-test-cmake-${build_type_lower}-out.log\n"
                "      ${CURRENT_BUILDTREES_DIR}/build-test-cmake-${build_type_lower}-err.log\n"
            )
        endif()
    endforeach()
endmacro()

function(vcpkg_cmake_config_test)
    if (NOT _VCPKG_EDITABLE)
        # Skip cmake test
        return()
    endif()

    cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "USAGE;TARGET_NAMES;HEADERS;FUNCTIONS")
    # First, we should get the cmake targets automanticlly
    if ((arg_USAGE AND NOT arg_TARGET_NAMES) OR (NOT arg_USAGE AND arg_TARGET_NAMES))
        message(FATAL_ERROR "USAGE and TARGET_NAMES must be declared at same time!")
    endif()

    if (arg_USAGE)
        set(target_usage "${arg_USAGE}")
        set(target_names ${arg_TARGET_NAMES})
    else()
        z_get_cmake_targets()
    endif()

    if (NOT target_usage OR NOT target_names)
        # Skip cmake test because the cmake configuration is not exported
        message(STATUS "Could not find the cmake configuration file, skip test the cmake configuration.")
        return()
    endif()

    set(extern_header_checks "")
    set(extern_symbol_checks_base "")
    set(extern_symbol_check_symbol "")
    if (arg_HEADERS)
        foreach(header IN LISTS arg_HEADERS)
            vcpkg_list(APPEND extern_header_checks "#include <${header}>\n")
        endforeach()
    endif()

    if (arg_FUNCTIONS)
        set(extern_symbol_checks_base "typedef int (*symbol_func)(void);\n\n")
        foreach(symbol IN LISTS arg_FUNCTIONS)
            set(extern_symbol_check_symbol "symbol_func func = (symbol_func)&${symbol};\nreturn func();\n")
        endforeach()
    endif()

    foreach(target_name IN LISTS target_names)
        # Write a sample CMakeLists.txt and source file
        z_write_sample_code(${target_name})
        # Build
        z_build_with_toolchain()
    endforeach()
    unset(extern_symbol_check_symbol)
    unset(extern_symbol_checks_base)
    unset(extern_header_checks)
endfunction()
