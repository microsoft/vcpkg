function(z_vcpkg_fixup_rpath_in_dir)
    vcpkg_find_acquire_program(PATCHELF)

    # We need to iterate trough everything because we
    # can't predict where an elf file will be located
    file(GLOB root_entries LIST_DIRECTORIES TRUE "${CURRENT_PACKAGES_DIR}/*")

    # Skip some folders for better throughput
    list(APPEND folders_to_skip "include")
    list(JOIN folders_to_skip "|" folders_to_skip_regex)
    set(folders_to_skip_regex "^(${folders_to_skip_regex})$")

    foreach(folder IN LISTS root_entries)
        if(NOT IS_DIRECTORY "${folder}")
            continue()
        endif()

        get_filename_component(folder_name "${folder}" NAME)
        if(folder_name MATCHES "${folders_to_skip_regex}")
            continue()
        endif()

        file(GLOB_RECURSE elf_files LIST_DIRECTORIES FALSE "${folder}/*")
        foreach(elf_file IN LISTS elf_files)
            if(IS_SYMLINK "${elf_file}")
                continue()
            endif()

            get_filename_component(elf_file_dir "${elf_file}" DIRECTORY)

            set(current_prefix "${CURRENT_PACKAGES_DIR}")
            if(elf_file_dir MATCHES "debug/")
                set(current_prefix "${CURRENT_PACKAGES_DIR}/debug")
            endif()

            # compute path relative to lib
            file(RELATIVE_PATH relative_to_lib "${elf_file_dir}" "${current_prefix}/lib")
            if(relative_to_lib STREQUAL "")
                set(rpath "\$ORIGIN")
            else()
                set(rpath "\$ORIGIN:\$ORIGIN/${relative_to_lib}")
            endif()

            # If this fails, the file is not an elf
            execute_process(
                COMMAND "${PATCHELF}" --set-rpath "${rpath}" "${elf_file}"
                OUTPUT_QUIET
                ERROR_VARIABLE set_rpath_error
            )
            if("${set_rpath_error}" STREQUAL "")
                message(STATUS "Fixed rpath: ${elf_file} (${rpath})")
            endif()
        endforeach()
    endforeach()
endfunction()

z_vcpkg_fixup_rpath_in_dir()
