#[===[.md:
# vcpkg_cmake_config_fixup

Merge release and debug CMake targets and configs to support multiconfig generators.

Additionally corrects common issues with targets, such as absolute paths and incorrectly placed binaries.

```cmake
vcpkg_cmake_config_fixup(
    [PACKAGE_NAME <name>]
    [CONFIG_PATH <config-directory>]
    [TOOLS_PATH <tools/${PORT}>]
    [DO_NOT_DELETE_PARENT_CONFIG_PATH]
    [NO_PREFIX_CORRECTION]
)
```

For many ports, `vcpkg_cmake_config_fixup()` on its own should work,
as `PACKAGE_NAME` defaults to `${PORT}` and `CONFIG_PATH` defaults to `share/${PACKAGE_NAME}`.
For ports where the package name passed to `find_package` is distinct from the port name,
`PACKAGE_NAME` should be changed to be that name instead.
For ports where the directory of the `*config.cmake` files cannot be set,
use the `CONFIG_PATH` to change the directory where the files come from.

By default the parent directory of CONFIG_PATH is removed if it is named "cmake".
Passing the `DO_NOT_DELETE_PARENT_CONFIG_PATH` option disable such behavior,
as it is convenient for ports that install
more than one CMake package configuration file.

The `NO_PREFIX_CORRECTION` option disables the correction of `_IMPORT_PREFIX`
done by vcpkg due to moving the config files.
Currently the correction does not take into account how the files are moved,
and applies a rather simply correction which in some cases will yield the wrong results.

## How it Works

1. Moves `/debug/<CONFIG_PATH>/*targets-debug.cmake` to `/share/${PACKAGE_NAME}`.
2. Transforms all references matching `/bin/*.exe` to `/${TOOLS_PATH}/*.exe` on Windows.
3. Transforms all references matching `/bin/*` to `/${TOOLS_PATH}/*` on other platforms.
4. Fixes `${_IMPORT_PREFIX}` in auto generated targets.
5. Replaces `${CURRENT_INSTALLED_DIR}` with `${_IMPORT_PREFIX}` in configs.
6. Merges INTERFACE_LINK_LIBRARIES of release and debug configurations.
7. Replaces `${CURRENT_INSTALLED_DIR}` with `${VCPKG_IMPORT_PREFIX}` in targets.
8. Removes `/debug/<CONFIG_PATH>/*config.cmake`.

## Examples

* [concurrentqueue](https://github.com/Microsoft/vcpkg/blob/master/ports/concurrentqueue/portfile.cmake)
* [curl](https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake)
* [nlohmann-json](https://github.com/Microsoft/vcpkg/blob/master/ports/nlohmann-json/portfile.cmake)
#]===]
if(Z_VCPKG_CMAKE_CONFIG_FIXUP_GUARD)
    return()
endif()
set(Z_VCPKG_CMAKE_CONFIG_FIXUP_GUARD ON CACHE INTERNAL "guard variable")

function(vcpkg_cmake_config_fixup)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "DO_NOT_DELETE_PARENT_CONFIG_PATH;NO_PREFIX_CORRECTION" "PACKAGE_NAME;CONFIG_PATH;TOOLS_PATH" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_cmake_config_fixup was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT arg_PACKAGE_NAME)
        set(arg_PACKAGE_NAME "${PORT}")
    endif()
    if(NOT arg_CONFIG_PATH)
        set(arg_CONFIG_PATH "share/${arg_PACKAGE_NAME}")
    endif()
    if(NOT arg_TOOLS_PATH)
        set(arg_TOOLS_PATH "tools/${PORT}")
    endif()
    set(target_path "share/${arg_PACKAGE_NAME}")

    string(REPLACE "." "\\." EXECUTABLE_SUFFIX "${VCPKG_TARGET_EXECUTABLE_SUFFIX}")

    set(debug_share "${CURRENT_PACKAGES_DIR}/debug/${target_path}")
    set(release_share "${CURRENT_PACKAGES_DIR}/${target_path}")

    if(NOT arg_CONFIG_PATH STREQUAL "share/${arg_PACKAGE_NAME}")
        if(arg_CONFIG_PATH STREQUAL "share")
            set(arg_CONFIG_PATH z_vcpkg_share)
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/${arg_CONFIG_PATH}")
            file(RENAME "${CURRENT_PACKAGES_DIR}/share" "${CURRENT_PACKAGES_DIR}/${arg_CONFIG_PATH}")
        endif()

        set(debug_config "${CURRENT_PACKAGES_DIR}/debug/${arg_CONFIG_PATH}")
        set(release_config "${CURRENT_PACKAGES_DIR}/${arg_CONFIG_PATH}")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            if(NOT EXISTS "${debug_config}")
                message(FATAL_ERROR "'${debug_config}' does not exist.")
            endif()

            # This roundabout handling enables CONFIG_PATH = share
            file(MAKE_DIRECTORY "${debug_share}")
            file(GLOB files "${debug_config}/*")
            file(COPY ${files} DESTINATION "${debug_share}")
            file(REMOVE_RECURSE "${debug_config}")
        endif()

        file(GLOB files "${release_config}/*")
        file(COPY ${files} DESTINATION "${release_share}")
        file(REMOVE_RECURSE "${release_config}")

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            get_filename_component(debug_config_dir_name "${debug_config}" NAME)
            string(TOLOWER "${debug_config_dir_name}" debug_config_dir_name)
            if(debug_config_dir_name STREQUAL "cmake" AND NOT arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
                file(REMOVE_RECURSE "${debug_config}")
            else()
                get_filename_component(debug_config_parent_dir "${debug_config}" DIRECTORY)
                get_filename_component(debug_config_dir_name "${debug_config_parent_dir}" NAME)
                string(TOLOWER "${debug_config_dir_name}" debug_config_dir_name)
                if(debug_config_dir_name STREQUAL "cmake" AND NOT arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
                    file(REMOVE_RECURSE "${debug_config_parent_dir}")
                endif()
            endif()
        endif()

        get_filename_component(release_config_dir_name "${release_config}" NAME)
        string(TOLOWER "${release_config_dir_name}" release_config_dir_name)
        if(release_config_dir_name STREQUAL "cmake" AND NOT arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
            file(REMOVE_RECURSE "${release_config}")
        else()
            get_filename_component(release_config_parent_dir "${release_config}" DIRECTORY)
            get_filename_component(release_config_dir_name "${release_config_parent_dir}" NAME)
            string(TOLOWER "${release_config_dir_name}" release_config_dir_name)
            if(release_config_dir_name STREQUAL "cmake" AND NOT arg_DO_NOT_DELETE_PARENT_CONFIG_PATH)
                file(REMOVE_RECURSE "${release_config_parent_dir}")
            endif()
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        if(NOT EXISTS "${debug_share}")
            message(FATAL_ERROR "'${debug_share}' does not exist.")
        endif()
    endif()

    file(GLOB_RECURSE release_targets
        "${release_share}/*-release.cmake"
    )
    foreach(release_target IN LISTS release_targets)
        file(READ "${release_target}" contents)
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${_IMPORT_PREFIX}" contents "${contents}")
        string(REGEX REPLACE "\\\${_IMPORT_PREFIX}/bin/([^ \"]+${EXECUTABLE_SUFFIX})" "\${_IMPORT_PREFIX}/${arg_TOOLS_PATH}/\\1" contents "${contents}")
        file(WRITE "${release_target}" "${contents}")
    endforeach()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(GLOB_RECURSE debug_targets
            "${debug_share}/*-debug.cmake"
            )
        foreach(debug_target IN LISTS debug_targets)
            file(RELATIVE_PATH debug_target_rel "${debug_share}" "${debug_target}")

            file(READ "${debug_target}" contents)
            string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${_IMPORT_PREFIX}" contents "${contents}")
            string(REGEX REPLACE "\\\${_IMPORT_PREFIX}/bin/([^ \";]+${EXECUTABLE_SUFFIX})" "\${_IMPORT_PREFIX}/${arg_TOOLS_PATH}/\\1" contents "${contents}")
            string(REPLACE "\${_IMPORT_PREFIX}/lib" "\${_IMPORT_PREFIX}/debug/lib" contents "${contents}")
            string(REPLACE "\${_IMPORT_PREFIX}/bin" "\${_IMPORT_PREFIX}/debug/bin" contents "${contents}")
            file(WRITE "${release_share}/${debug_target_rel}" "${contents}")

            file(REMOVE "${debug_target}")
        endforeach()
    endif()

    #Fix ${_IMPORT_PREFIX} and absolute paths in cmake generated targets and configs;
    #Since those can be renamed we have to check in every *.cmake, but only once.
    file(GLOB_RECURSE main_cmakes "${release_share}/*.cmake")
    if(NOT DEFINED Z_VCPKG_CMAKE_CONFIG_ALREADY_FIXED_UP)
        vcpkg_list(SET Z_VCPKG_CMAKE_CONFIG_ALREADY_FIXED_UP)
    endif()
    foreach(already_fixed_up IN LISTS Z_VCPKG_CMAKE_CONFIG_ALREADY_FIXED_UP)
        vcpkg_list(REMOVE_ITEM main_cmakes "${already_fixed_up}")
    endforeach()
    vcpkg_list(APPEND Z_VCPKG_CMAKE_CONFIG_ALREADY_FIXED_UP ${main_cmakes})
    set(Z_VCPKG_CMAKE_CONFIG_ALREADY_FIXED_UP "${Z_VCPKG_CMAKE_CONFIG_ALREADY_FIXED_UP}" CACHE INTERNAL "")

    foreach(main_cmake IN LISTS main_cmakes)
        file(READ "${main_cmake}" contents)
        # Note: I think the following comment is no longer true, since we now require the path to be `share/blah`
        # however, I don't know it for sure.
        # - nimazzuc

        #This correction is not correct for all cases. To make it correct for all cases it needs to consider
        #original folder deepness to CURRENT_PACKAGES_DIR in comparison to the moved to folder deepness which
        #is always at least (>=) 2, e.g. share/${PORT}. Currently the code assumes it is always 2 although
        #this requirement is only true for the *Config.cmake. The targets are not required to be in the same
        #folder as the *Config.cmake!
        if(NOT arg_NO_PREFIX_CORRECTION)
            string(REGEX REPLACE
[[get_filename_component\(_IMPORT_PREFIX "\${CMAKE_CURRENT_LIST_FILE}" PATH\)(
get_filename_component\(_IMPORT_PREFIX "\${_IMPORT_PREFIX}" PATH\))*]]
[[get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)]]
                contents "${contents}") # see #1044 for details why this replacement is necessary. See #4782 why it must be a regex.
            string(REGEX REPLACE
[[get_filename_component\(PACKAGE_PREFIX_DIR "\${CMAKE_CURRENT_LIST_DIR}/\.\./(\.\./)*" ABSOLUTE\)]]
[[get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)]]
                contents "${contents}")
            string(REGEX REPLACE
[[get_filename_component\(PACKAGE_PREFIX_DIR "\${CMAKE_CURRENT_LIST_DIR}/\.\.((\\|/)\.\.)*" ABSOLUTE\)]]
[[get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)]]
                contents "${contents}") # This is a meson-related workaround, see https://github.com/mesonbuild/meson/issues/6955
        endif()

        # Merge release and debug configurations of target property INTERFACE_LINK_LIBRARIES.
        string(REPLACE "${release_share}/" "${debug_share}/" debug_cmake "${main_cmake}")
        if(DEFINED VCPKG_BUILD_TYPE)
            # Skip. Warning: A release-only port in a dual-config installation
            # may pull release dependencies into the debug configuration.
        elseif(NOT contents MATCHES "INTERFACE_LINK_LIBRARIES")
            # Skip. No relevant properties.
        elseif(NOT contents MATCHES "# Generated CMake target import file\\.")
            # Skip. No safe assumptions about a matching debug import file.
        elseif(NOT EXISTS "${debug_cmake}")
            message(SEND_ERROR "Did not find a debug import file matching '${main_cmake}'")
        else()
            file(READ "${debug_cmake}" debug_contents)
            while(contents MATCHES "set_target_properties\\(([^ \$]*) PROPERTIES[^)]*\\)")
                set(matched_command "${CMAKE_MATCH_0}")
                string(REPLACE "+" "\\+" target "${CMAKE_MATCH_1}")
                if(NOT debug_contents MATCHES "set_target_properties\\(${target} PROPERTIES[^)]*\\)")
                    message(SEND_ERROR "Did not find a debug configuration for target '${target}'.")
                endif()
                set(debug_command "${CMAKE_MATCH_0}")
                string(REGEX MATCH "  INTERFACE_LINK_LIBRARIES \"([^\"]*)\"" release_line "${matched_command}")
                set(release_libs "${CMAKE_MATCH_1}")
                string(REGEX MATCH "  INTERFACE_LINK_LIBRARIES \"([^\"]*)\"" debug_line "${debug_command}")
                set(debug_libs "${CMAKE_MATCH_1}")
                z_vcpkg_cmake_config_fixup_merge(merged_libs release_libs debug_libs)
                string(REPLACE "${release_line}" "  INTERFACE_LINK_LIBRARIES \"${merged_libs}\"" updated_command "${matched_command}")
                string(REPLACE "set_target_properties" "set_target_properties::done" updated_command "${updated_command}") # Prevend 2nd match
                string(REPLACE "${matched_command}" "${updated_command}" contents "${contents}")
            endwhile()
            string(REPLACE "set_target_properties::done" "set_target_properties" contents "${contents}") # Restore original command
        endif()

        #Fix absolute paths to installed dir with ones relative to ${CMAKE_CURRENT_LIST_DIR}
        #This happens if vcpkg built libraries are directly linked to a target instead of using
        #an imported target.
        string(REPLACE "${CURRENT_INSTALLED_DIR}" [[${VCPKG_IMPORT_PREFIX}]] contents "${contents}")
        file(TO_CMAKE_PATH "${CURRENT_PACKAGES_DIR}" cmake_current_packages_dir)
        string(REPLACE "${cmake_current_packages_dir}" [[${VCPKG_IMPORT_PREFIX}]] contents "${contents}")
        # If ${VCPKG_IMPORT_PREFIX} was actually used, inject a definition of it:
        string(FIND "${contents}" [[${VCPKG_IMPORT_PREFIX}]] index)
        if (NOT index STREQUAL "-1")
            get_filename_component(main_cmake_dir "${main_cmake}" DIRECTORY)
            # Calculate relative to be a sequence of "../"
            file(RELATIVE_PATH relative "${main_cmake_dir}" "${cmake_current_packages_dir}")
            string(PREPEND contents "get_filename_component(VCPKG_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_DIR}\/${relative}\" ABSOLUTE)\n")
        endif()

        file(WRITE "${main_cmake}" "${contents}")
    endforeach()

    file(GLOB_RECURSE unused_files
        "${debug_share}/*[Tt]argets.cmake"
        "${debug_share}/*[Cc]onfig.cmake"
        "${debug_share}/*[Cc]onfigVersion.cmake"
        "${debug_share}/*[Cc]onfig-version.cmake"
    )
    foreach(unused_file IN LISTS unused_files)
        file(REMOVE "${unused_file}")
    endforeach()

    # Remove /debug/<target_path>/ if it's empty.
    file(GLOB_RECURSE remaining_files "${debug_share}/*")
    if(remaining_files STREQUAL "")
        file(REMOVE_RECURSE "${debug_share}")
    endif()

    # Remove /debug/share/ if it's empty.
    file(GLOB_RECURSE remaining_files "${CURRENT_PACKAGES_DIR}/debug/share/*")
    if(remaining_files STREQUAL "")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    endif()
endfunction()

# Merges link interface library lists for release and debug
# into a single expression which use generator expression as necessary.
function(z_vcpkg_cmake_config_fixup_merge out_var release_var debug_var)
    set(release_libs "VCPKG;${${release_var}}")
    string(REGEX REPLACE ";optimized;([^;]*)" ";\\1" release_libs "${release_libs}")
    string(REGEX REPLACE ";debug;([^;]*)" ";" release_libs "${release_libs}")
    list(REMOVE_AT release_libs 0)
    list(FILTER release_libs EXCLUDE REGEX [[^\\[$]<\\[$]<CONFIG:DEBUG>:]])
    list(TRANSFORM release_libs REPLACE [[^\\[$]<\\[$]<NOT:\\[$]<CONFIG:DEBUG>>:(.*)>$]] "\\1")

    set(debug_libs "VCPKG;${${debug_var}}")
    string(REGEX REPLACE ";optimized;([^;]*)" ";" debug_libs "${debug_libs}")
    string(REGEX REPLACE ";debug;([^;]*)" ";\\1" debug_libs "${debug_libs}")
    list(REMOVE_AT debug_libs 0)
    list(FILTER debug_libs EXCLUDE REGEX [[^\\[$]<\\[$]<NOT:\\[$]<CONFIG:DEBUG>>:]])
    list(TRANSFORM debug_libs REPLACE [[^\\[$]<\\[$]<CONFIG:DEBUG>:(.*)>$]] "\\1")

    set(merged_libs "")
    foreach(release_lib debug_lib IN ZIP_LISTS release_libs debug_libs)
        if(release_lib STREQUAL debug_lib)
            list(APPEND merged_libs "${release_lib}")
        else()
            if(release_lib)
                list(APPEND merged_libs "\\\$<\\\$<NOT:\\\$<CONFIG:DEBUG>>:${release_lib}>")
            endif()
            if(debug_lib)
                list(APPEND merged_libs "\\\$<\\\$<CONFIG:DEBUG>:${debug_lib}>")
            endif()
        endif()
    endforeach()
    set("${out_var}" "${merged_libs}" PARENT_SCOPE)
endfunction()
