# Preferred to CMake's file(COPY) due to potential Windows command line length limitations. Some added convenience.
#
# param FROM_DIRECTORY - string, required. source directory to copy files from
# param TO_DIRECTORY - string, required. destination directory to copy files to
# param COPIED_FILES_RESULT - list<string>, optional, output variable. list of copied files
# param EXTENSIONS - list<string>, optional. For convenience, allowed values are [ DLL | EXE | PDB | CONF | SO | O | INI | TXT ]
# param FILE_PATTERNS - list<string>, optional. File pattern regexes to match, e.g. "*.dll" or "myfile*.txt" or whatever
function(vcpkg_copy_from_directory)

    set(one_value_args_ FROM_DIRECTORY TO_DIRECTORY COPIED_FILES_RESULT)
    set(multi_value_args_ EXTENSIONS FILE_PATTERNS)
    cmake_parse_arguments(vcpkg_copy_from_directory "" "${one_value_args_}" "${multi_value_args_}" ${ARGN})

    if (NOT vcpkg_copy_from_directory_FROM_DIRECTORY)
        message(FATAL_ERROR "vcpkg_copy_from_directory: Missing required argument 'FROM_DIRECTORY'")
    endif()
    if (NOT vcpkg_copy_from_directory_TO_DIRECTORY)
        message(FATAL_ERROR "vcpkg_copy_from_directory: Missing required argument 'TO_DIRECTORY'")
    endif()

    # Ensure the source directory exists
    if (NOT EXISTS "${vcpkg_copy_from_directory_FROM_DIRECTORY}")
        message(FATAL_ERROR "vcpkg_copy_from_directory: Source directory does not exist: ${vcpkg_copy_from_directory_FROM_DIRECTORY}")
    endif()

    # Check that we don't have any unwanted EXTENSIONS
    set(allowed_file_extensions_list_ "DLL" "EXE" "PDB" "CONF" "SO" "O" "INI" "TXT")
    foreach (extension_ IN LISTS vcpkg_copy_from_directory_EXTENSIONS)
        if (NOT "${extension_}" IN_LIST allowed_file_extensions_list_)
            list(JOIN allowed_file_extensions_list_ ", " allowed_file_extensions_list_string_)
            message(FATAL_ERROR "vcpkg_copy_from_directory: Invalid EXTENSIONS -'${extension_}'. Allowed values are '${allowed_file_extensions_list_string_}'")
        endif()
    endforeach()

    # for returning to the caller, and avoiding duplicates
    set(from_copied_files_ "")
    set(to_copied_files_ "")

    set(patterns_to_copy_ "${vcpkg_copy_from_directory_FILE_PATTERNS}")

    if ("DLL" IN_LIST vcpkg_copy_from_directory_EXTENSIONS)
        list(APPEND patterns_to_copy_ "*.dll")
    endif()

    if ("EXE" IN_LIST vcpkg_copy_from_directory_EXTENSIONS)
        list(APPEND patterns_to_copy_ "*.exe")
    endif()

    if ("PDB" IN_LIST vcpkg_copy_from_directory_EXTENSIONS)
        list(APPEND patterns_to_copy_ "*.pdb")
    endif()

    if ("CONF" IN_LIST vcpkg_copy_from_directory_EXTENSIONS)
        list(APPEND patterns_to_copy_ "*.conf")
    endif()

    if ("SO" IN_LIST vcpkg_copy_from_directory_EXTENSIONS)
        list(APPEND patterns_to_copy_ "*.so")
    endif()

    if ("O" IN_LIST vcpkg_copy_from_directory_EXTENSIONS)
        list(APPEND patterns_to_copy_ "*.o")
    endif()

    if ("INI" IN_LIST vcpkg_copy_from_directory_EXTENSIONS)
        list(APPEND patterns_to_copy_ "*.ini")
    endif()

    if ("TXT" IN_LIST vcpkg_copy_from_directory_EXTENSIONS)
        list(APPEND patterns_to_copy_ "*.txt")
    endif()

    # Ensure the destination directory exists
    file(MAKE_DIRECTORY "${vcpkg_copy_from_directory_TO_DIRECTORY}")

    foreach (pattern_ IN LISTS patterns_to_copy_)

        cmake_path(APPEND vcpkg_copy_from_directory_FROM_DIRECTORY "${pattern_}" OUTPUT_VARIABLE full_path_pattern_)
        file(GLOB matched_files_ "${full_path_pattern_}"
                LIST_DIRECTORIES FALSE
        )
        foreach (file_match_ IN LISTS matched_files_)
            # skip if already copied
            if ("${file_match_}" IN_LIST all_copied_files_)
                message(STATUS "Skipping file ${file_match_} - already copied.")
                continue()
            endif()
            # do the copying
            get_filename_component(file_name_ "${file_match_}" NAME)
            cmake_path(APPEND vcpkg_copy_from_directory_TO_DIRECTORY "${file_name_}" OUTPUT_VARIABLE to_file_)
            file(
                    COPY_FILE "${file_match_}" "${to_file_}"
                    RESULT copy_result_
                    ONLY_IF_DIFFERENT
                    INPUT_MAY_BE_RECENT
            )
            if (NOT copy_result_ EQUAL 0)
                message(FATAL_ERROR "vcpkg_copy_from_directory: Failed to copy file ${file_match_} to ${to_file_}")
            endif()
            message(STATUS "Copied file from ${file_match_} to ${to_file_}")
            list(APPEND from_copied_files_ "${file_match_}")
            list(APPEND to_copied_files_ "${to_file_}")
        endforeach()

    endforeach()

    if (vcpkg_copy_from_directory_COPIED_FILES_RESULT)
        set(${vcpkg_copy_from_directory_COPIED_FILES_RESULT} "${to_copied_files_}" PARENT_SCOPE)
    endif()

endfunction()
