include_guard(GLOBAL)
# This function is called through find_path or find_program to validate that the program works
function(z_vcpkg_try_find_acquire_tool_validator result candidate)
    # all arg_XXX variables are set in vcpkg_find_acquire_tool's cmake_parse_arguments
    vcpkg_execute_in_download_mode(
        COMMAND ${arg_INTERPRETER} ${candidate} ${arg_VERSION_COMMAND}
        WORKING_DIRECTORY "${VCPKG_ROOT_DIR}"
        OUTPUT_VARIABLE program_version_output
        ERROR_VARIABLE program_version_output
    )

    # Given VERSION_PREFIX is "my fancy program" and program_version_output is
    # "my fancy program   1.2.0", extract the dots-numeric part
    if(DEFINED arg_VERSION_PREFIX)
        string(FIND
            "${program_version_output}"
            "${arg_VERSION_PREFIX}" prefix_offset)
        # If there's no matching prefix, this isn't even the program we're looking for, so fail
        if(prefix_offset EQUAL -1)
            set("${result}" FALSE PARENT_SCOPE)
            return()
        endif()

        string(LENGTH "${arg_VERSION_PREFIX}" prefix_length)
        math(EXPR prefix_end "${prefix_offset} + ${prefix_length}")

        string(SUBSTRING "${program_version_output}" "${prefix_end}" -1 program_version_output)

        if(NOT "${program_version_output}" MATCHES "^[ \t\n\r]*([0-9.]+)")
            set("${result}" FALSE PARENT_SCOPE)
            return()
        endif()

        set(program_version_output "${CMAKE_MATCH_1}")
    else()
        string(STRIP "${program_version_output}" program_version_output)
    endif()

    set(version_compare VERSION_GREATER_EQUAL)
    set(version_compare_msg "at least")
    if(arg_EXACT_VERSION)
        set(version_compare VERSION_EQUAL)
        set(version_compare_msg "exactly")
    endif()

    if("${program_version_output}" ${version_compare} "${arg_VERSION}")
        message(STATUS "Found ${arg_TOOL_NAME} ${program_version_output}: ${candidate}")
        set("${result}" TRUE PARENT_SCOPE)
    else()
        message(STATUS "Skipping ${arg_TOOL_NAME} ${program_version_output} ${candidate} because \
${version_compare_msg} ${arg_VERSION} is required!")
        set("${result}" FALSE PARENT_SCOPE)
    endif()
endfunction()

function(vcpkg_find_acquire_tool)
    set(switch_args)
    set(single_args)
    set(multi_args)

    # outputs
    list(APPEND single_args
        OUT_TOOL_COMMAND # command list to supply to execute_process
        OUT_DOWNLOAD_TOOL_DIRECTORY # if the tool was downloaded, set to
            # ${DOWNLOADS}/tools/TOOL_SUBDIRECTORY
            # otherwise not set.
        )

    # metadata
    list(APPEND switch_args EXACT_VERSION) # forbid newer versions
    list(APPEND single_args
        TOOL_NAME # what do we call you?
        VERSION # what version or minimum version are we looking for?
        VERSION_PREFIX # what output prefixes your version output
        # example:
        # bion@BION-OFFICE:~$ python --version
        # Python 3.10.12
        # VERSION_PREFIX is "Python "
        APK_PACKAGE_NAME
        APT_PACKAGE_NAME # also used with apt-get
        BREW_PACKAGE_NAME
        DNF_PACKAGE_NAME # also used with yum
        ZYPPER_PACKAGE_NAME)
    list(APPEND multi_args
        INTERPRETER # if the tool is a script, a list of command line tokens used as a prefix
                    # example: /usr/bin/mono
                    # example: /usr/bin/python3;-I
        SEARCH_NAMES # aliases for the command name; defaults to TOOL_NAME
                     # example: meson;meson.py
        SEARCH_PATHS # paths from the system where this might be found
                # example: C:/Program Files/Python312;C:/Program Files/Python311;C:/Program Files/Python310   ....
                # Always includes ${DOWNLOADS}/tools/${TOOL_SUBDIRECTORY} if download is possible
        VERSION_COMMAND # command tokens to add after a candidate intended to produce version output
        )

    # download information, choose exactly zero or one mode
    list(APPEND multi_args URLS) # trigger this mode and supply download URIs
    list(APPEND single_args
        DOWNLOAD_FILENAME # ${DOWNLOADS}/DOWNLOAD_FILENAME
        SHA512
        TOOL_SUBDIRECTORY # ${DOWNLOADS}/tools/TOOL_SUBDIRECTORY
                          # usually only used to distingush platform
                          # default: TOOL_NAME-VERSION
        )

    # mode: RAW_BINARY (the tool is downloaded in a runnable state)
    list(APPEND switch_args RAW_BINARY) # trigger this mode
    list(APPEND single_args RENAME_BINARY_TO)

    # mode: archive (the tool is distributed in some form of archive)
    list(APPEND single_args ARCHIVE_SUBDIRECTORY) # a subdirectory of the archive that is meaningful
                                                    # this is renamed to OUT_DOWNLOAD_TOOL_DIRECTORY, and all other
                                                    # archive contents discarded
    list(APPEND multi_args PATCHES)                 # patches to apply after resolving extraction

    cmake_parse_arguments(PARSE_ARGV 0 "arg" "${switch_args}" "${single_args}" "${multi_args}")

    foreach(arg_name IN ITEMS OUT_TOOL_COMMAND TOOL_NAME)
        if(NOT DEFINED "arg_${arg_name}")
            message(FATAL_ERROR "${arg_name} is required.")
        endif()
    endforeach()

    # consistency check download mode vs. not args
    if(DEFINED arg_URLS)
        set(download_possible TRUE)
        foreach(arg_name IN ITEMS DOWNLOAD_FILENAME SHA512)
            if(NOT DEFINED "arg_${arg_name}")
                message(FATAL_ERROR "When download is supported, ${arg_name} is required.")
            endif()
        endforeach()
    else()
        set(download_possible FALSE)
        foreach(arg_name IN ITEMS DOWNLOAD_FILENAME SHA512 TOOL_SUBDIRECTORY RENAME_BINARY_TO ARCHIVE_SUBDIRECTORY PATCHES)
            if(DEFINED "arg_${arg_name}")
                message(FATAL_ERROR "${arg_name} are only used when downloading and thus can't be used when downloading is not possible. Add sources to URLS.")
            endif()
        endforeach()
        if(RAW_BINARY)
            message(FATAL_ERROR "RAW_BINARY is only used when downloading and thus can't be used when downloading is not possible. Add sources to URLS.")
        endif()
    endif()

    # consistency check RAW_BINARY mode vs. archive mode
    if(download_possible)
        if (arg_RAW_BINARY)
            foreach(arg_name IN ITEMS ARCHIVE_SUBDIRECTORY PATCHES)
                if(DEFINED "arg_${arg_name}")
                    message(FATAL_ERROR "${arg_name} can't be used in RAW_BINARY download mode.")
                endif()
            endforeach()
        else()
            if(DEFINED arg_RENAME_BINARY_TO)
                message(FATAL_ERROR "RENAME_BINARY_TO can only be used with RAW_BINARY download mode.")
            endif()
        endif()
    endif()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unrecognized arguments: ${arg_UNPARSED_ARGUMENTS}.")
    endif()

    if(download_possible)
        if(NOT DEFINED arg_TOOL_SUBDIRECTORY)
            set(arg_TOOL_SUBDIRECTORY "${arg_TOOL_NAME}")
            if (DEFINED arg_VERSION)
                string(APPEND arg_TOOL_SUBDIRECTORY "-${arg_VERSION}")
            endif()
        endif()

        set(download_tool_directory "${DOWNLOADS}/tools/${arg_TOOL_SUBDIRECTORY}")
    endif()

    if(NOT DEFINED arg_SEARCH_NAMES)
        set(arg_SEARCH_NAMES "${arg_TOOL_NAME}")
    endif()

    if(download_possible)
	    # prefer the downloaded copy if we have downloaded it before
        find_program(tool_path
            NAMES ${arg_SEARCH_NAMES}
            PATHS "${download_tool_directory}"
            VALIDATOR z_vcpkg_try_find_acquire_tool_validator
            NO_CACHE
            NO_DEFAULT_PATH)
    endif()

    if(NOT tool_path)
        find_program(tool_path
            NAMES ${arg_SEARCH_NAMES}
            HINTS ${arg_SEARCH_PATHS}
            VALIDATOR z_vcpkg_try_find_acquire_tool_validator
            NO_CACHE
            NO_PACKAGE_ROOT_PATH
            NO_CMAKE_PATH
            NO_CMAKE_ENVIRONMENT_PATH)
    endif()

    if(tool_path)
        if(DEFINED arg_OUT_DOWNLOAD_ROOT)
            unset("${arg_OUT_DOWNLOAD_ROOT}" PARENT_SCOPE)
        endif()
    else()
        # Neither downloaded nor from the system, try to download
        if(NOT download_possible)
            # Can't acquire, generate an error message.
            # Note leading two spaces to avoid cmake doubling every newline in a FATAL_ERROR message.
            if(CMAKE_HOST_WIN32)
                message(FATAL_ERROR "Could not find a usable ${arg_TOOL_NAME}, you might be able to fix this by installing it.")
            endif()

            set(message "Could not find a usable ${arg_TOOL_NAME}. You might be able to fix this by installing it from your system package manager. For example:\n")
            foreach(system_manager IN ITEMS brew apt dnf zypper apk)
                string(TOUPPER "${system_manager}" SYSTEM_MANAGER)
                if(DEFINED arg_${SYSTEM_MANAGER}_PACKAGE_NAME)
                    find_program("${SYSTEM_MANAGER}" NAMES "${system_manager}" NO_CACHE)
                    if(${SYSTEM_MANAGER})
                        string(APPEND message "  ${system_manager} install ${arg_${SYSTEM_MANAGER}_PACKAGE_NAME}\n")
                    endif()
                endif()
            endforeach()

            if(DEFINED arg_APT_PACKAGE_NAME AND NOT APT)
                find_program(APT_GET NAMES apt-get NO_CACHE)
                if(APT_GET)
                    string(APPEND message "  apt-get install ${arg_APT_PACKAGE_NAME}\n")
                endif()
            endif()

            if(DEFINED arg_DNF_PACKAGE_NAME AND NOT DNF)
                find_program(YUM NAMES yum NO_CACHE)
                if(YUM)
                    string(APPEND message "  yum install ${arg_DNF_PACKAGE_NAME}\n")
                endif()
            endif()

            message(FATAL_ERROR "${message}")
        endif()

        vcpkg_download_distfile(download_path
            URLS ${arg_URLS}
            SHA512 "${arg_SHA512}"
            FILENAME "${arg_DOWNLOAD_FILENAME}"
        )

        if(arg_RAW_BINARY)
            file(MAKE_DIRECTORY "${download_tool_directory}")
            if(DEFINED arg_RENAME_BINARY_TO)
                set(rename_arg RENAME "${arg_RENAME_BINARY_TO}")
            else()
                set(rename_arg)
            endif()

            file(INSTALL "${download_path}"
                DESTINATION "${download_tool_directory}"
                ${rename_arg}
                FILE_PERMISSIONS
                    OWNER_READ OWNER_WRITE OWNER_EXECUTE
                    GROUP_READ GROUP_EXECUTE
                    WORLD_READ WORLD_EXECUTE
            )
        else()
            if(DEFINED arg_ARCHIVE_SUBDIRECTORY)
                string(RANDOM random_suffix)
                set(temp_download_directory "${DOWNLOADS}/temp/${arg_TOOL_SUBDIRECTORY}_${random_suffix}")
                vcpkg_extract_archive(
                    ARCHIVE "${download_path}"
                    DESTINATION "${temp_download_directory}"
                )

                file(RENAME "${temp_download_directory}/${arg_ARCHIVE_SUBDIRECTORY}" "${download_tool_directory}")
                file(REMOVE_RECURSE "${temp_download_directory}")
            else()
                vcpkg_extract_archive(
                    ARCHIVE "${download_path}"
                    DESTINATION "${download_tool_directory}"
                )
            endif()
        endif()

        find_program(tool_path
            NAMES ${arg_SEARCH_NAMES}
            PATHS "${download_tool_directory}"
            VALIDATOR z_vcpkg_try_find_acquire_tool_validator
            REQUIRED
            NO_CACHE
            NO_DEFAULT_PATH
        )

        if(DEFINED arg_OUT_DOWNLOAD_ROOT)
            set("${arg_OUT_DOWNLOAD_ROOT}" "${extracted_root}" PARENT_SCOPE)
        endif()
    endif()

    set("${arg_OUT_TOOL_COMMAND}" ${arg_INTERPRETER} "${tool_path}" PARENT_SCOPE)
endfunction()
