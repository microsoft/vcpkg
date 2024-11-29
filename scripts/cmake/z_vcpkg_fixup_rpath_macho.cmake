function(z_vcpkg_calculate_corrected_macho_rpath)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
      ""
      "MACHO_FILE_DIR;OUT_NEW_RPATH_VAR"
      "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(current_prefix "${CURRENT_PACKAGES_DIR}")
    set(current_installed_prefix "${CURRENT_INSTALLED_DIR}")
    file(RELATIVE_PATH relative_from_packages "${CURRENT_PACKAGES_DIR}" "${arg_MACHO_FILE_DIR}")
    if("${relative_from_packages}/" MATCHES "^debug/" OR "${relative_from_packages}/" MATCHES "^(manual-)?tools/.*/debug/.*")
        set(current_prefix "${CURRENT_PACKAGES_DIR}/debug")
        set(current_installed_prefix "${CURRENT_INSTALLED_DIR}/debug")
    endif()

    # compute path relative to lib
    file(RELATIVE_PATH relative_to_lib "${arg_MACHO_FILE_DIR}" "${current_prefix}/lib")
    # remove trailing slash
    string(REGEX REPLACE "/+$" "" relative_to_lib "${relative_to_lib}")

    if(NOT relative_to_lib STREQUAL "")
        set(new_rpath "@loader_path/${relative_to_lib}")
    else()
        set(new_rpath "@loader_path")
    endif()

    set("${arg_OUT_NEW_RPATH_VAR}" "${new_rpath}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_regex_escape)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
      ""
      "STRING;OUT_REGEX_ESCAPED_STRING_VAR"
      "")
  string(REGEX REPLACE "([][+.*()^])" "\\\\\\1" regex_escaped "${arg_STRING}")
  set("${arg_OUT_REGEX_ESCAPED_STRING_VAR}" "${regex_escaped}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_fixup_macho_rpath_in_dir)
    # We need to iterate through everything because we
    # can't predict where a Mach-O file will be located
    file(GLOB root_entries LIST_DIRECTORIES TRUE "${CURRENT_PACKAGES_DIR}/*")

    # Skip some folders for better throughput
    list(APPEND folders_to_skip "include")
    list(JOIN folders_to_skip "|" folders_to_skip_regex)
    set(folders_to_skip_regex "^(${folders_to_skip_regex})$")

    find_program(
        install_name_tool_cmd
        NAMES install_name_tool
        DOC "Absolute path of install_name_tool cmd"
        REQUIRED
    )

    find_program(
        otool_cmd
        NAMES otool
        DOC "Absolute path of otool cmd"
        REQUIRED
    )

    find_program(
        file_cmd
        NAMES file
        DOC "Absolute path of file cmd"
        REQUIRED
      )

    foreach(folder IN LISTS root_entries)
        if(NOT IS_DIRECTORY "${folder}")
            continue()
        endif()

        get_filename_component(folder_name "${folder}" NAME)
        if(folder_name MATCHES "${folders_to_skip_regex}")
            continue()
        endif()

        file(GLOB_RECURSE macho_files LIST_DIRECTORIES FALSE "${folder}/*")
        list(FILTER macho_files EXCLUDE REGEX [[\.(cpp|cc|cxx|c|hpp|h|hh|hxx|inc|json|toml|yaml|man|m4|ac|am|in|log|txt|pyi?|pyc|pyx|pxd|pc|cmake|f77|f90|f03|fi|f|cu|mod|ini|whl|cat|csv|rst|md|npy|npz|template|build)$]])
        list(FILTER macho_files EXCLUDE REGEX "/(copyright|LICENSE|METADATA)$")

        foreach(macho_file IN LISTS macho_files)
            if(IS_SYMLINK "${macho_file}")
                continue()
            endif()

            # Determine if the file is a Mach-O executable or shared library
            execute_process(
                COMMAND "${file_cmd}" -b "${macho_file}"
                OUTPUT_VARIABLE file_output
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            if(file_output MATCHES ".*Mach-O.*shared library.*")
                set(file_type "shared")
            elseif(file_output MATCHES ".*Mach-O.*executable.*")
                set(file_type "executable")
            else()
                debug_message("File `${macho_file}` reported as `${file_output}` is not a Mach-O file")
                continue()
            endif()

            list(APPEND macho_executables_and_shared_libs "${macho_file}")

            get_filename_component(macho_file_dir "${macho_file}" DIRECTORY)
            get_filename_component(macho_file_name "${macho_file}" NAME)

            z_vcpkg_calculate_corrected_macho_rpath(
                MACHO_FILE_DIR "${macho_file_dir}"
                OUT_NEW_RPATH_VAR new_rpath
            )

            if("${file_type}" STREQUAL "shared")
                # Set the install name for shared libraries
                execute_process(
                    COMMAND "${otool_cmd}" -D "${macho_file}"
                    OUTPUT_VARIABLE get_id_ov
                    RESULT_VARIABLE get_id_rv
                )
                if(NOT get_id_rv EQUAL 0)
                    message(FATAL_ERROR "Could not obtain install name id from '${macho_file}'")
                endif()
                set(macho_new_id "@rpath/${macho_file_name}")
                message(STATUS "Setting install name id of '${macho_file}' to '@rpath/${macho_file_name}'")
                execute_process(
                    COMMAND "${install_name_tool_cmd}" -id "${macho_new_id}" "${macho_file}"
                    OUTPUT_QUIET
                    ERROR_VARIABLE set_id_error
                    RESULT_VARIABLE set_id_exit_code
                )
                if(NOT "${set_id_error}" STREQUAL "" AND NOT set_id_exit_code EQUAL 0)
                    message(WARNING "Couldn't adjust install name of '${macho_file}': ${set_id_error}")
                    continue()
                endif()

                # otool -D <macho_file> typically returns lines like:

                # <macho_file>:
                # <id>

                # But also with ARM64 binaries, it can return:
                # <macho_file> (architecture arm64):
                # <id>

                # Either way we need to remove the first line and trim the trailing newline char.
                string(REGEX REPLACE "[^\n]+:\n" "" get_id_ov "${get_id_ov}")
                string(REGEX REPLACE "\n.*" "" get_id_ov "${get_id_ov}")
                list(APPEND adjusted_shared_lib_old_ids "${get_id_ov}")
                list(APPEND adjusted_shared_lib_new_ids "${macho_new_id}")
            endif()

            # List all existing rpaths
            execute_process(
                COMMAND "${otool_cmd}" -l "${macho_file}"
                OUTPUT_VARIABLE get_rpath_ov
                RESULT_VARIABLE get_rpath_rv
            )

            if(NOT get_rpath_rv EQUAL 0)
                message(FATAL_ERROR "Could not obtain rpath list from '${macho_file}'")
            endif()
            # Extract the LC_RPATH load commands and extract the paths
            string(REGEX REPLACE "[^\n]+cmd LC_RPATH\n[^\n]+\n[^\n]+path ([^\n]+) \\(offset[^\n]+\n" "rpath \\1\n" get_rpath_ov "${get_rpath_ov}")
            string(REGEX MATCHALL "rpath [^\n]+" get_rpath_ov "${get_rpath_ov}")
            string(REGEX REPLACE "rpath " "" rpath_list "${get_rpath_ov}")

            list(FIND rpath_list "${new_rpath}" has_new_rpath)
            if(NOT has_new_rpath EQUAL -1)
                list(REMOVE_AT rpath_list ${has_new_rpath})
                set(rpath_args)
            else()
                set(rpath_args -add_rpath "${new_rpath}")
            endif()
            foreach(rpath IN LISTS rpath_list)
                list(APPEND rpath_args "-delete_rpath" "${rpath}")
            endforeach()
            if(NOT rpath_args)
                continue()
            endif()

            # Set the new rpath
            execute_process(
                COMMAND "${install_name_tool_cmd}" ${rpath_args} "${macho_file}"
                OUTPUT_QUIET
                ERROR_VARIABLE set_rpath_error
                RESULT_VARIABLE set_rpath_exit_code
            )

            if(NOT "${set_rpath_error}" STREQUAL "" AND NOT set_rpath_exit_code EQUAL 0)
                message(WARNING "Couldn't adjust RPATH of '${macho_file}': ${set_rpath_error}")
                continue()
            endif()

            message(STATUS "Adjusted RPATH of '${macho_file}' to '${new_rpath}'")
        endforeach()
    endforeach()

    # Check for dependent libraries in executables and shared libraries that
    # need adjusting after id change
    list(LENGTH adjusted_shared_lib_old_ids last_adjusted_index)
    if(NOT last_adjusted_index EQUAL 0)
        math(EXPR last_adjusted_index "${last_adjusted_index} - 1")
        foreach(macho_file IN LISTS macho_executables_and_shared_libs)
            execute_process(
                COMMAND "${otool_cmd}" -L "${macho_file}"
                OUTPUT_VARIABLE get_deps_ov
                RESULT_VARIABLE get_deps_rv
            )
            if(NOT get_deps_rv EQUAL 0)
                message(FATAL_ERROR "Could not obtain dependencies list from '${macho_file}'")
            endif()
            # change adjusted_shared_lib_old_ids[i] -> adjusted_shared_lib_new_ids[i]
            foreach(i RANGE ${last_adjusted_index})
                list(GET adjusted_shared_lib_old_ids ${i} adjusted_old_id)
                z_vcpkg_regex_escape(
                    STRING "${adjusted_old_id}"
                    OUT_REGEX_ESCAPED_STRING_VAR regex
                )
                if(NOT get_deps_ov MATCHES "[ \t]${regex} ")
                    continue()
                endif()
                list(GET adjusted_shared_lib_new_ids ${i} adjusted_new_id)

                # Replace the old id with the new id
                execute_process(
                    COMMAND "${install_name_tool_cmd}" -change "${adjusted_old_id}" "${adjusted_new_id}" "${macho_file}"
                    OUTPUT_QUIET
                    ERROR_VARIABLE change_id_error
                    RESULT_VARIABLE change_id_exit_code
                )
                if(NOT "${change_id_error}" STREQUAL "" AND NOT change_id_exit_code EQUAL 0)
                    message(WARNING "Couldn't adjust dependent shared library install name in '${macho_file}': ${change_id_error}")
                    continue()
                endif()
                message(STATUS "Adjusted dependent shared library install name in '${macho_file}' (From '${adjusted_old_id}' -> To '${adjusted_new_id}')")
            endforeach()
        endforeach()
    endif()
endfunction()
