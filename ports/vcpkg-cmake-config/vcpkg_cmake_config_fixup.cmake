#[===[.md:
# vcpkg_cmake_config_fixup

Merge release and debug CMake targets and configs to support multiconfig generators.

Additionally corrects common issues with targets, such as absolute paths and incorrectly placed binaries.

```cmake
vcpkg_cmake_config_fixup(
    [PACKAGE_NAME <name>]
    [CONFIG_PATH <config-directory>]
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
2. Removes `/debug/<CONFIG_PATH>/*config.cmake`.
3. Transform all references matching `/bin/*.exe` to `/tools/<port>/*.exe` on Windows.
4. Transform all references matching `/bin/*` to `/tools/<port>/*` on other platforms.
5. Fixes `${_IMPORT_PREFIX}` in auto generated targets.
6. Replace `${CURRENT_INSTALLED_DIR}` with `${_IMPORT_PREFIX}` in configs and targets.

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
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "DO_NOT_DELETE_PARENT_CONFIG_PATH" "PACKAGE_NAME;CONFIG_PATH;NO_PREFIX_CORRECTION" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_cmake_config_fixup was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT arg_PACKAGE_NAME)
        set(arg_PACKAGE_NAME "${PORT}")
    endif()
    if(NOT arg_CONFIG_PATH)
        set(arg_CONFIG_PATH "share/${arg_PACKAGE_NAME}")
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

    file(GLOB_RECURSE unused_files
        "${debug_share}/*[Tt]argets.cmake"
        "${debug_share}/*[Cc]onfig.cmake"
        "${debug_share}/*[Cc]onfigVersion.cmake"
        "${debug_share}/*[Cc]onfig-version.cmake"
    )
    foreach(unused_file IN LISTS unused_files)
        file(REMOVE "${unused_file}")
    endforeach()

    file(GLOB_RECURSE release_targets
        "${release_share}/*-release.cmake"
    )
    foreach(release_target IN LISTS release_targets)
        file(READ "${release_target}" contents)
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${_IMPORT_PREFIX}" contents "${contents}")
        string(REGEX REPLACE "\\\${_IMPORT_PREFIX}/bin/([^ \"]+${EXECUTABLE_SUFFIX})" "\${_IMPORT_PREFIX}/tools/${PORT}/\\1" contents "${contents}")
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
            string(REGEX REPLACE "\\\${_IMPORT_PREFIX}/bin/([^ \";]+${EXECUTABLE_SUFFIX})" "\${_IMPORT_PREFIX}/tools/${PORT}/\\1" contents "${contents}")
            string(REPLACE "\${_IMPORT_PREFIX}/lib" "\${_IMPORT_PREFIX}/debug/lib" contents "${contents}")
            string(REPLACE "\${_IMPORT_PREFIX}/bin" "\${_IMPORT_PREFIX}/debug/bin" contents "${contents}")
            file(WRITE "${release_share}/${debug_target_rel}" "${contents}")

            file(REMOVE "${debug_target}")
        endforeach()
    endif()

    #Fix ${_IMPORT_PREFIX} in cmake generated targets and configs;
    #Since those can be renamed we have to check in every *.cmake
    file(GLOB_RECURSE main_cmakes "${release_share}/*.cmake")

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

        #Fix wrongly absolute paths to install dir with the correct dir using ${_IMPORT_PREFIX}
        #This happens if vcpkg built libraries are directly linked to a target instead of using
        #an imported target for it. We could add more logic here to identify defect target files.
        #Since the replacement here in a multi config build always requires a generator expression
        #in front of the absoulte path to ${CURRENT_INSTALLED_DIR}. So the match should always be at
        #least >:${CURRENT_INSTALLED_DIR}.
        #In general the following generator expressions should be there:
        #\$<\$<CONFIG:DEBUG>:${CURRENT_INSTALLED_DIR}/debug/lib/somelib>
        #and/or
        #\$<\$<NOT:\$<CONFIG:DEBUG>>:${CURRENT_INSTALLED_DIR}/lib/somelib>
        #with ${CURRENT_INSTALLED_DIR} being fully expanded
        string(REPLACE "${CURRENT_INSTALLED_DIR}" [[${_IMPORT_PREFIX}]] contents "${contents}")

        # Patch out any remaining absolute references
        file(TO_CMAKE_PATH "${CURRENT_PACKAGES_DIR}" cmake_current_packages_dir)
        string(REPLACE "${CMAKE_CURRENT_PACKAGES_DIR}" [[${_IMPORT_PREFIX}]] contents "${contents}")

        file(WRITE "${main_cmake}" "${contents}")
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


