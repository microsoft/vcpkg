include_guard(GLOBAL)
# This function is called through find_path or find_program to validate that the program works
function(z_vcpkg_try_find_acquire_tool_validator result candidate)
    vcpkg_execute_in_download_mode(
        COMMAND ${candidate} ${arg_VERSION_COMMAND}
        WORKING_DIRECTORY "${VCPKG_ROOT_DIR}"
        OUTPUT_VARIABLE program_version_output
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
    if(${arg_EXACT_VERSION_MATCH})
        set(version_compare VERSION_EQUAL)
        set(version_compare_msg "exact")
    endif()

    if("${program_version_output}" ${version_compare} "${arg_MIN_VERSION}")
        message(STATUS "Found ${arg_TOOL_NAME} ('${program_version_output}'): ${candidate}")
        set("${result}" TRUE PARENT_SCOPE)
    else()
        message(STATUS "Skipping ${arg_TOOL_NAME} ('${program_version_output}') ${candidate} because \
${version_compare_msg} ${arg_MIN_VERSION} is required!")
        set("${result}" FALSE PARENT_SCOPE)
    endif()
endfunction()

function(z_vcpkg_try_find_existing_tool)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        "EXACT_VERSION_MATCH"
        "OUT_TOOL_PATH;TOOL_NAME;MIN_VERSION;VERSION_PREFIX;INTERPRETER"
        "SEARCH_NAMES;PATHS_TO_SEARCH;VERSION_COMMAND"
        )

    foreach(arg_name IN ITEMS OUT_TOOL_PATH TOOL_NAME)
        if(NOT DEFINED "arg_${arg_name}")
            message(FATAL_ERROR "${arg_name} is required.")
        endif()
    endforeach()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unrecognized arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    # Do the actual find
    debug_message("PATHS_TO_SEARCH ${arg_PATHS_TO_SEARCH}")
    find_program(tool_path
        NAMES ${arg_SEARCH_NAMES}
        HINTS ${arg_PATHS_TO_SEARCH}
        VALIDATOR z_vcpkg_try_find_acquire_tool_validator
        NO_CACHE
        NO_PACKAGE_ROOT_PATH
        NO_CMAKE_PATH
        NO_CMAKE_ENVIRONMENT_PATH
        )

    if(DEFINED tool_path)
        set("${arg_OUT_TOOL_PATH}" "${tool_path}" PARENT_SCOPE)
    endif()
endfunction()

function(vcpkg_find_acquire_tool)
    set(single_args
        OUT_TOOL_PATH
        OUT_TOOL_ACQUIRED
        OUT_EXTRACTED_ROOT
        TOOL_NAME
        VERSION
        DOWNLOAD_FILENAME
        SHA512
        RENAME_BINARY_TO
        TOOL_SUBDIRECTORY
        BREW_PACKAGE_NAME
        APT_PACKAGE_NAME
        DNF_PACKAGE_NAME
        ZYPPER_PACKAGE_NAME
        APK_PACKAGE_NAME
        VERSION_PREFIX
        INTERPRETER
    )

    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        "RAW_EXECUTABLE;EXACT_VERSION_MATCH"
        "${single_args}"
        "SEARCH_NAMES;URLS;PATHS_TO_SEARCH;VERSION_COMMAND"
    )

    foreach(arg_name IN ITEMS OUT_TOOL_PATH TOOL_NAME)
        if(NOT DEFINED "arg_${arg_name}")
            message(FATAL_ERROR "${arg_name} is required.")
        endif()
    endforeach()

    if(DEFINED "arg_URLS")
        foreach(arg_name IN ITEMS URLS SHA512 DOWNLOAD_FILENAME)
            if(NOT DEFINED "arg_${arg_name}")
                message(FATAL_ERROR "When download is supported, ${ARG_NAME} is required.")
            endif()
        endforeach()
    endif()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unrecognized arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(full_subdirectory "${DOWNLOADS}/tools/${arg_TOOL_NAME}")
    if(NOT "${arg_TOOL_SUBDIRECTORY}" STREQUAL "")
        string(APPEND full_subdirectory "/${arg_TOOL_SUBDIRECTORY}")
    endif()

    vcpkg_list(PREPEND arg_PATHS_TO_SEARCH "${full_subdirectory}")
    if("${arg_SEARCH_NAMES}" STREQUAL "")
        set(arg_SEARCH_NAMES "${arg_TOOL_NAME}")
    endif()

    set(out_tool_acquired "OFF")

    vcpkg_list(SET search_args
        OUT_TOOL_PATH out_tool_path
        TOOL_NAME "${arg_TOOL_NAME}"
	MIN_VERSION "${arg_VERSION}"
        SEARCH_NAMES ${arg_SEARCH_NAMES}
        PATHS_TO_SEARCH ${arg_PATHS_TO_SEARCH}
    )
    if(exact_version_match)
        vcpkg_list(APPEND search_args EXACT_VERSION_MATCH)
    endif()
    if(DEFINED arg_VERSION_COMMAND)
        vcpkg_list(APPEND search_args VERSION_COMMAND ${arg_VERSION_COMMAND})
    endif()
    if(DEFINED arg_VERSION_PREFIX)
        vcpkg_list(APPEND search_args VERSION_PREFIX "${arg_VERSION_PREFIX}")
    endif()
    if(DEFINED arg_INTERPRETER)
        vcpkg_list(APPEND search_args INTERPRETER "${arg_INTERPRETER}")
    endif()

    z_vcpkg_try_find_existing_tool(${search_args})

    if(NOT out_tool_path)
        # Neither downloaded nor from the system, try to download
        if(NOT DEFINED arg_URLS)
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

        set(out_tool_acquired "ON")
        vcpkg_download_distfile(archive_path
            URLS ${arg_URLS}
            SHA512 "${arg_SHA512}"
            FILENAME "${arg_DOWNLOAD_FILENAME}"
        )

        if(arg_RAW_EXECUTABLE)
            file(MAKE_DIRECTORY "${full_subdirectory}")
            if("${arg_RENAME_BINARY_TO}" STREQUAL "")
                file(COPY "${archive_path}"
                    DESTINATION "${full_subdirectory}"
                    FILE_PERMISSIONS
                        OWNER_READ OWNER_WRITE OWNER_EXECUTE
                        GROUP_READ GROUP_EXECUTE
                        WORLD_READ WORLD_EXECUTE
                )
            else()
                file(INSTALL "${archive_path}"
                    DESTINATION "${full_subdirectory}"
                    RENAME "${arg_RENAME_BINARY_TO}"
                    FILE_PERMISSIONS
                        OWNER_READ OWNER_WRITE OWNER_EXECUTE
                        GROUP_READ GROUP_EXECUTE
                        WORLD_READ WORLD_EXECUTE
                )
            endif()
        else()
            z_vcpkg_extract_archive(
                ARCHIVE "${archive_path}"
                DESTINATION "${full_subdirectory}"
            )
        endif()

        z_vcpkg_try_find_existing_tool(${search_args})
        if(NOT out_tool_path)
            message(FATAL_ERROR "Downloaded ${arg_DOWNLOAD_FILENAME} but could not find ${arg_TOOL_NAME} inside it.")
        endif()
    endif()

    set("${arg_OUT_TOOL_PATH}" "${out_tool_path}" PARENT_SCOPE)
    if(NOT "${arg_OUT_TOOL_ACQUIRED}" STREQUAL "")
        set("${arg_OUT_TOOL_ACQUIRED}" "${out_tool_acquired}" PARENT_SCOPE)
    endif()
    if(NOT "${arg_OUT_EXTRACTED_ROOT}" STREQUAL "")
        set("${arg_OUT_EXTRACTED_ROOT}" "${full_subdirectory}" PARENT_SCOPE)
    endif()
endfunction()
