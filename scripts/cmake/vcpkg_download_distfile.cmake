function(z_vcpkg_check_hash result file_path sha512)
    file(SHA512 "${file_path}" file_hash)
    string(COMPARE EQUAL "${file_hash}" "${sha512}" hash_match)
    set("${result}" "${hash_match}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_download_distfile_test_hash file_path kind error_advice sha512 skip_sha512)
    if(_VCPKG_INTERNAL_NO_HASH_CHECK)
        # When using the internal hash skip, do not output an explicit message.
        return()
    endif()
    if(skip_sha512)
        message(STATUS "Skipping hash check for ${file_path}.")
        return()
    endif()

    set(hash_match OFF)
    z_vcpkg_check_hash(hash_match "${file_path}" "${sha512}")

    if(NOT hash_match)
        message(FATAL_ERROR
            "\nFile does not have expected hash:\n"
            "        File path: [ ${file_path} ]\n"
            "    Expected hash: [ ${sha512} ]\n"
            "      Actual hash: [ ${file_hash} ]\n"
            "${error_advice}\n")
    endif()
endfunction()

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

    if(EXISTS "${downloaded_file_path}" AND NOT arg_SKIP_SHA512)
        set(hash_match OFF)
        z_vcpkg_check_hash(hash_match "${downloaded_file_path}" "${arg_SHA512}")
        
        if(NOT hash_match)
            get_filename_component(filename_component "${arg_FILENAME}" NAME_WE)
            get_filename_component(extension_component "${arg_FILENAME}" EXT)
            get_filename_component(directory_component "${arg_FILENAME}" DIRECTORY)

            string(SUBSTRING "${arg_SHA512}" 0 8 hash)
            set(arg_FILENAME "${directory_component}${filename_component}-${hash}${extension_component}")
            set(downloaded_file_path "${DOWNLOADS}/${arg_FILENAME}")
        endif()
    endif()

    # check if file with same name already exists in downloads
    if(EXISTS "${downloaded_file_path}" AND NOT arg_ALWAYS_REDOWNLOAD)
        set(advice_message "The cached file SHA512 doesn't match. The file may have been corrupted.")
        if(_VCPKG_NO_DOWNLOADS)
            string(APPEND advice_message " Downloads are disabled please provide a valid file at path ${downloaded_file_path} and retry.")
        else()
            string(APPEND advice_message " To re-download this file please delete cached file at path ${downloaded_file_path} and retry.")
        endif()

        z_vcpkg_download_distfile_test_hash(
            "${downloaded_file_path}"
            "cached file"
            "${advice_message}"
            "${arg_SHA512}"
            "${arg_SKIP_SHA512}"
        )
        message(STATUS "Using cached ${arg_FILENAME}.")
    endif()

    # vcpkg_download_distfile_ALWAYS_REDOWNLOAD only triggers when NOT _VCPKG_NO_DOWNLOADS
    # this could be de-morgan'd out but it's more clear this way
    if(_VCPKG_NO_DOWNLOADS)
        if(NOT EXISTS "${downloaded_file_path}")
            message(FATAL_ERROR "Downloads are disabled, but '${downloaded_file_path}' does not exist.")
        endif()

        set("${out_var}" "${downloaded_file_path}" PARENT_SCOPE)
        return()
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

    if(NOT EXISTS "${downloaded_file_path}" OR arg_ALWAYS_REDOWNLOAD)
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
    endif()

    set("${out_var}" "${downloaded_file_path}" PARENT_SCOPE)
endfunction()
