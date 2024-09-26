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

            get_filename_component(macho_file_dir "${macho_file}" DIRECTORY)
            get_filename_component(macho_file_name "${macho_file}" NAME)

            z_vcpkg_calculate_corrected_macho_rpath(
                MACHO_FILE_DIR "${macho_file_dir}"
                OUT_NEW_RPATH_VAR new_rpath
            )

            if("${file_type}" STREQUAL "shared")
                # Set the install name for shared libraries
                execute_process(
                    COMMAND "${install_name_tool_cmd}" -id "@rpath/${macho_file_name}" "${macho_file}"
                    OUTPUT_QUIET
                    ERROR_VARIABLE set_id_error
                )
                message(STATUS "Set install name id of '${macho_file}' to '@rpath/${macho_file_name}'")
                if(NOT "${set_id_error}" STREQUAL "")
                    message(WARNING "Couldn't adjust install name of '${macho_file}': ${set_id_error}")
                    continue()
                endif()
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
            if(rpath_args STREQUAL "")
                continue()
            endif()

            # Set the new rpath
            execute_process(
                COMMAND "${install_name_tool_cmd}" ${rpath_args} "${macho_file}"
                OUTPUT_QUIET
                ERROR_VARIABLE set_rpath_error
            )

            if(NOT "${set_rpath_error}" STREQUAL "")
                message(WARNING "Couldn't adjust RPATH of '${macho_file}': ${set_rpath_error}")
                continue()
            endif()

            message(STATUS "Adjusted RPATH of '${macho_file}' to '${new_rpath}'")
        endforeach()
    endforeach()
endfunction()
