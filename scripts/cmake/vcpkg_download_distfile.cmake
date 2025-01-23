function(vcpkg_download_distfile out_var)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        "SKIP_SHA512;SILENT_EXIT;QUIET;ALWAYS_REDOWNLOAD"
        "FILENAME;SHA512"
        "URLS;HEADERS"
    )

    if(NOT DEFINED arg_URLS)
        message(FATAL_ERROR "vcpkg_download_distfile requires a URLS argument.")
    endif()
    if(NOT DEFINED arg_FILENAME)
        message(FATAL_ERROR "vcpkg_download_distfile requires a FILENAME argument.")
    endif()
    if(arg_SILENT_EXIT)
        message(WARNING "SILENT_EXIT has been deprecated as an argument to vcpkg_download_distfile -- remove the argument to resolve this warning")
    endif()

    # Note that arg_ALWAYS_REDOWNLOAD implies arg_SKIP_SHA512, and NOT arg_SKIP_SHA512 implies NOT arg_ALWAYS_REDOWNLOAD
    if(arg_ALWAYS_REDOWNLOAD AND NOT arg_SKIP_SHA512)
        message(FATAL_ERROR "ALWAYS_REDOWNLOAD option requires SKIP_SHA512 as well")
    endif()

    if(NOT arg_SKIP_SHA512 AND NOT DEFINED arg_SHA512)
        message(FATAL_ERROR "vcpkg_download_distfile requires a SHA512 argument.
If you do not know the SHA512, add it as 'SHA512 0' and re-run this command.")
    elseif(arg_SKIP_SHA512 AND DEFINED arg_SHA512)
        message(FATAL_ERROR "vcpkg_download_distfile must not be passed both SHA512 and SKIP_SHA512.")
    endif()

    if(_VCPKG_INTERNAL_NO_HASH_CHECK)
        set(arg_SKIP_SHA512 1)
    endif()

    if(NOT arg_SKIP_SHA512)
        if("${arg_SHA512}" STREQUAL "0")
            string(REPEAT 0 128 arg_SHA512)
        else()
            string(LENGTH "${arg_SHA512}" arg_SHA512_length)
            if(NOT "${arg_SHA512_length}" EQUAL "128" OR NOT "${arg_SHA512}" MATCHES "^[a-zA-Z0-9]*$")
                message(FATAL_ERROR "Invalid SHA512: ${arg_SHA512}.
    If you do not know the file's SHA512, set this to \"0\".")
            endif()

            string(TOLOWER "${arg_SHA512}" arg_SHA512)
        endif()
    endif()

    set(downloaded_file_path "${DOWNLOADS}/${arg_FILENAME}")

    if(EXISTS "${downloaded_file_path}")
        if(arg_SKIP_SHA512)
            if(NOT arg_ALWAYS_REDOWNLOAD)
                if(NOT _VCPKG_INTERNAL_NO_HASH_CHECK)
                    message(STATUS "Skipping hash check and using cached ${arg_FILENAME}.")
                endif()

                set("${out_var}" "${downloaded_file_path}" PARENT_SCOPE)
                return()
            endif()
        else()
            file(SHA512 "${downloaded_file_path}" file_hash)
            if("${file_hash}" STREQUAL "${sha512}")
                # Note that NOT arg_SKIP_SHA512 implies NOT arg_ALWAYS_REDOWNLOAD
                message(STATUS "Using cached ${arg_FILENAME}.")
                set("${out_var}" "${downloaded_file_path}" PARENT_SCOPE)
                return()
            endif()

            # The existing file hash mismatches. Perhaps the expected SHA512 changed. Try adding the expected SHA512
            # into the file name and try again to hopefully not conflict.
            get_filename_component(filename_component "${arg_FILENAME}" NAME_WE)
            get_filename_component(extension_component "${arg_FILENAME}" EXT)
            get_filename_component(directory_component "${arg_FILENAME}" DIRECTORY)

            string(SUBSTRING "${arg_SHA512}" 0 8 hash)
            set(arg_FILENAME "${directory_component}${filename_component}-${hash}${extension_component}")
            set(downloaded_file_path "${DOWNLOADS}/${arg_FILENAME}")
        endif()
    endif()

    if(EXISTS "${downloaded_file_path}" AND NOT arg_ALWAYS_REDOWNLOAD)
        if(_VCPKG_NO_DOWNLOADS)
            set(advice_message "note: Downloads are disabled. Please ensure that the expected file is placed at ${downloaded_file_path} and retry.")
        else()
            set(advice_message "note: To re-download this file, delete ${downloaded_file_path} and retry.")
        endif()

        if(arg_SKIP_SHA512)
            if(NOT _VCPKG_INTERNAL_NO_HASH_CHECK)
                message(STATUS "Skipping hash check for ${file_path}.")
            endif()
        else()
            file(SHA512 "${downloaded_file_path}" file_hash)
            if(NOT ("${file_hash}" STREQUAL "${arg_SHA512}"))
                message(FATAL_ERROR
                    "\n${downloaded_file_path}: error: the existing downloaded file has a different SHA512 than expected, it may have been corrupted.\n"
                    "Expected: ${arg_SHA512}\n"
                    "Actual  : ${file_hash}\n"
                    "${advice_message}\n")
            endif()
        endif()

        message(STATUS "Using cached ${arg_FILENAME}.")
        set("${out_var}" "${downloaded_file_path}" PARENT_SCOPE)
        return()
    endif()

    # vcpkg_download_distfile_ALWAYS_REDOWNLOAD only triggers when NOT _VCPKG_NO_DOWNLOADS
    # this could be de-morgan'd out but it's more clear this way
    if(_VCPKG_NO_DOWNLOADS)
        message(FATAL_ERROR "Downloads are disabled, but '${downloaded_file_path}' does not exist.")
    endif()

    vcpkg_list(SET urls_param)
    foreach(url IN LISTS arg_URLS)
        vcpkg_list(APPEND urls_param "--url=${url}")
    endforeach()

    vcpkg_list(SET headers_param)
    foreach(header IN LISTS arg_HEADERS)
        list(APPEND headers_param "--header=${header}")
    endforeach()

    if(arg_SKIP_SHA512)
        vcpkg_list(SET sha512_param "--skip-sha512")
    else()
        vcpkg_list(SET sha512_param "--sha512=${arg_SHA512}")
    endif()

    vcpkg_execute_in_download_mode(
        COMMAND "$ENV{VCPKG_COMMAND}" x-download
            "${downloaded_file_path}"
            ${sha512_param}
            ${urls_param}
            ${headers_param}
        RESULT_VARIABLE error_code
        WORKING_DIRECTORY "${DOWNLOADS}"
    )
    if(NOT "${error_code}" EQUAL "0")
        message(FATAL_ERROR "Download failed, halting portfile.")
    endif()

    set("${out_var}" "${downloaded_file_path}" PARENT_SCOPE)
endfunction()
