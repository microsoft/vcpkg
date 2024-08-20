function(z_vcpkg_calculate_corrected_rpath)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
      ""
      "ELF_FILE_DIR;ORG_RPATH;OUT_NEW_RPATH_VAR"
      "")

    set(current_prefix "${CURRENT_PACKAGES_DIR}")
    set(current_installed_prefix "${CURRENT_INSTALLED_DIR}")
    file(RELATIVE_PATH relative_from_packages "${CURRENT_PACKAGES_DIR}" "${arg_ELF_FILE_DIR}")
    if("${relative_from_packages}/" MATCHES "^debug/|^(manual-tools|tools)/[^/]*/debug/")
        set(current_prefix "${CURRENT_PACKAGES_DIR}/debug")
        set(current_installed_prefix "${CURRENT_INSTALLED_DIR}/debug")
    endif()

    # compute path relative to lib
    file(RELATIVE_PATH relative_to_lib "${arg_ELF_FILE_DIR}" "${current_prefix}/lib")
    # compute path relative to prefix
    file(RELATIVE_PATH relative_to_prefix "${arg_ELF_FILE_DIR}" "${current_prefix}")

    set(rpath_norm "")
    if(NOT "${arg_ORG_RPATH}" STREQUAL "")
        cmake_path(CONVERT "${arg_ORG_RPATH}" TO_CMAKE_PATH_LIST rpath_norm)

        # pattern matching helpers
        list(TRANSFORM rpath_norm PREPEND "::")
        list(TRANSFORM rpath_norm APPEND "/")

        string(REPLACE "::${arg_ELF_FILE_DIR}/" "::\$ORIGIN/" rpath_norm "${rpath_norm}")
        # Remove unnecessary up/down ; don't use normalize $ORIGIN/../ will be removed otherwise
        string(REPLACE "/lib/pkgconfig/../../" "/" rpath_norm "${rpath_norm}")
        # lib relative corrections
        string(REPLACE "::${current_prefix}/lib/" "::\$ORIGIN/${relative_to_lib}/" rpath_norm "${rpath_norm}")
        string(REPLACE "::${current_installed_prefix}/lib/" "::\$ORIGIN/${relative_to_lib}/" rpath_norm "${rpath_norm}")
        # prefix relativ
        string(REPLACE "::${current_prefix}/" "::\$ORIGIN/${relative_to_prefix}/" rpath_norm "${rpath_norm}")
        string(REPLACE "::${current_installed_prefix}/" "::\$ORIGIN/${relative_to_prefix}/" rpath_norm "${rpath_norm}")

        if(NOT X_VCPKG_RPATH_KEEP_SYSTEM_PATHS)
            list(FILTER rpath_norm INCLUDE REGEX "::\\\$ORIGIN.+") # Only keep paths relativ to ORIGIN
        endif()

        # Path normalization
        list(TRANSFORM rpath_norm REPLACE "/+" "/")

        # remove pattern matching helpers
        list(TRANSFORM rpath_norm REPLACE "^::" "")
        list(TRANSFORM rpath_norm REPLACE "/\$" "")
    endif()

    if(NOT relative_to_lib STREQUAL "")
        list(PREPEND rpath_norm "\$ORIGIN/${relative_to_lib}")
    endif()
    list(PREPEND rpath_norm "\$ORIGIN") # Make ORIGIN the first entry
    list(TRANSFORM rpath_norm REPLACE "/$" "")
    list(REMOVE_DUPLICATES rpath_norm)
    cmake_path(CONVERT "${rpath_norm}" TO_NATIVE_PATH_LIST new_rpath)

    set("${arg_OUT_NEW_RPATH_VAR}" "${new_rpath}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_fixup_rpath_in_dir)
    # We need to iterate trough everything because we
    # can't predict where an elf file will be located
    file(GLOB root_entries LIST_DIRECTORIES TRUE "${CURRENT_PACKAGES_DIR}/*")

    # Skip some folders for better throughput
    list(APPEND folders_to_skip "include")
    list(JOIN folders_to_skip "|" folders_to_skip_regex)
    set(folders_to_skip_regex "^(${folders_to_skip_regex})$")

    # In download mode, we don't know if we're going to need PATCHELF, so be pessimistic and fetch
    # it so it ends up in the downloads directory.
    if(VCPKG_DOWNLOAD_MODE)
        vcpkg_find_acquire_program(PATCHELF)
    endif()

    foreach(folder IN LISTS root_entries)
        if(NOT IS_DIRECTORY "${folder}")
            continue()
        endif()

        get_filename_component(folder_name "${folder}" NAME)
        if(folder_name MATCHES "${folders_to_skip_regex}")
            continue()
        endif()

        file(GLOB_RECURSE elf_files LIST_DIRECTORIES FALSE "${folder}/*")
        list(FILTER elf_files EXCLUDE REGEX "\\\.(a|cpp|cc|cxx|c|hpp|h|hh|hxx|inc|json|toml|yaml|man|m4|ac|am|in|log|txt|pyi?|pyc|pyx|pxd|pc|cmake|f77|f90|f03|fi|f|cu|mod|ini|whl|cat|csv|rst|md|npy|npz|template|build)$")
        list(FILTER elf_files EXCLUDE REGEX "/(copyright|LICENSE|METADATA)$")

        foreach(elf_file IN LISTS elf_files)
            if(IS_SYMLINK "${elf_file}")
                continue()
            endif()

            vcpkg_find_acquire_program(PATCHELF) # Note that this relies on vcpkg_find_acquire_program short
                                                 # circuiting after the first run
            # If this fails, the file is not an elf
            execute_process(
                COMMAND "${PATCHELF}" --print-rpath "${elf_file}"
                OUTPUT_VARIABLE readelf_output
                ERROR_VARIABLE read_rpath_error
            )
            string(REPLACE "\n" "" readelf_output "${readelf_output}")
            if(NOT "${read_rpath_error}" STREQUAL "")
                continue()
            endif()

            get_filename_component(elf_file_dir "${elf_file}" DIRECTORY)

            z_vcpkg_calculate_corrected_rpath(
              ELF_FILE_DIR "${elf_file_dir}"
              ORG_RPATH "${readelf_output}"
              OUT_NEW_RPATH_VAR new_rpath
            )

            execute_process(
                COMMAND "${PATCHELF}" --set-rpath "${new_rpath}" "${elf_file}"
                OUTPUT_QUIET
                ERROR_VARIABLE set_rpath_error
            )

            if(NOT "${set_rpath_error}" STREQUAL "")
                message(WARNING "Couldn't adjust RPATH of '${elf_file}': ${set_rpath_error}")
                continue()
            endif()

            message(STATUS "Adjusted RPATH of '${elf_file}' (From '${readelf_output}' -> To '${new_rpath}')")
        endforeach()
    endforeach()
endfunction()
