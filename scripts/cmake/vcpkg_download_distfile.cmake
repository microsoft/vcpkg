function(z_vcpkg_check_hash result file_path sha512)
    file(SHA512 "${file_path}" file_hash)
    string(TOLOWER "${sha512}" sha512_lower)
    string(COMPARE EQUAL "${file_hash}" "${sha512_lower}" hash_match)
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

function(z_vcpkg_download_distfile_show_proxy_and_fail error_code)
    message(FATAL_ERROR
        "    \n"
        "    Failed to download file with error: ${error_code}\n"  
        "    If you use a proxy, please check your proxy setting. Possible causes are:\n"
        "    \n"
        "    1. You are actually using an HTTP proxy, but setting HTTPS_PROXY variable\n"
        "       to `https://address:port`. This is not correct, because `https://` prefix\n"
        "       claims the proxy is an HTTPS proxy, while your proxy (v2ray, shadowsocksr\n"
        "       , etc..) is an HTTP proxy. Try setting `http://address:port` to both\n"
        "       HTTP_PROXY and HTTPS_PROXY instead.\n"
        "    \n"
        "    2. You are using Fiddler. Currently a bug (https://github.com/microsoft/vcpkg/issues/17752)\n"
        "       will set HTTPS_PROXY to `https://fiddler_address:port` which lead to problem 1 above.\n"
        "       Workaround is open Windows 10 Settings App, and search for Proxy Configuration page,\n"
        "       Change `http=address:port;https=address:port` to `address`, and fill the port number.\n"
        "    \n"
        "    3. Your proxy's remote server is out of service.\n"
        "    \n"
        "    In future vcpkg releases, if you are using Windows, you no longer need to set\n"
        "    HTTP(S)_PROXY environment variables. Vcpkg will simply apply Windows IE Proxy\n"
        "    Settings set by your proxy software. See (https://github.com/microsoft/vcpkg-tool/pull/49)\n"
        "    and (https://github.com/microsoft/vcpkg-tool/pull/77)\n"
        "    \n"
        "    Otherwise, please submit an issue at https://github.com/Microsoft/vcpkg/issues\n")
endfunction()

function(z_vcpkg_download_distfile_via_aria)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        "SKIP_SHA512"
        "FILENAME;SHA512"
        "URLS;HEADERS"
    )

    message(STATUS "Downloading ${arg_FILENAME}...")

    vcpkg_list(SET headers_param)
    foreach(header IN LISTS arg_HEADERS)
        vcpkg_list(APPEND headers_param "--header=${header}")
    endforeach()

    foreach(URL IN LISTS arg_URLS)
        debug_message("Download Command: ${ARIA2} ${URL} -o temp/${filename} -l download-${filename}-detailed.log ${headers_param}")
        vcpkg_execute_in_download_mode(
            COMMAND ${ARIA2} ${URL}
            -o temp/${arg_FILENAME}
            -l download-${arg_FILENAME}-detailed.log
            ${headers_param}
            OUTPUT_FILE download-${arg_FILENAME}-out.log
            ERROR_FILE download-${arg_FILENAME}-err.log
            RESULT_VARIABLE error_code
            WORKING_DIRECTORY "${DOWNLOADS}"
        )
        
        if ("${error_code}" STREQUAL "0")
            break()
        endif()
    endforeach()
    if (NOT "${error_code}" STREQUAL "0")
        message(STATUS
            "Downloading ${arg_FILENAME}... Failed.\n"
            "    Exit Code: ${error_code}\n"
            "    See logs for more information:\n"
            "        ${DOWNLOADS}/download-${arg_FILENAME}-out.log\n"
            "        ${DOWNLOADS}/download-${arg_FILENAME}-err.log\n"
            "        ${DOWNLOADS}/download-${arg_FILENAME}-detailed.log\n"
        )
        z_vcpkg_download_distfile_show_proxy_and_fail("${error_code}")
    else()
        z_vcpkg_download_distfile_test_hash(
            "${DOWNLOADS}/temp/${arg_FILENAME}"
            "downloaded file"
            "The file may have been corrupted in transit."
            "${arg_SHA512}"
            ${arg_SKIP_SHA512}
        )
        file(REMOVE
            ${DOWNLOADS}/download-${arg_FILENAME}-out.log
            ${DOWNLOADS}/download-${arg_FILENAME}-err.log
            ${DOWNLOADS}/download-${arg_FILENAME}-detailed.log
        )
        get_filename_component(downloaded_file_dir "${downloaded_file_path}" DIRECTORY)
        file(MAKE_DIRECTORY "${downloaded_file_dir}")
        file(RENAME "${DOWNLOADS}/temp/${arg_FILENAME}" "${downloaded_file_path}")
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

    set(download_file_path_part "${DOWNLOADS}/temp/${arg_FILENAME}")

    # Works around issue #3399
    # Delete "temp0" directory created by the old version of vcpkg
    file(REMOVE_RECURSE "${DOWNLOADS}/temp0")
    file(REMOVE_RECURSE "${DOWNLOADS}/temp")
    file(MAKE_DIRECTORY "${DOWNLOADS}/temp")

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

        if(NOT vcpkg_download_distfile_QUIET)
            message(STATUS "Using cached ${arg_FILENAME}.")
        endif()
        
        # Suppress the "Downloading ${arg_URLS} -> ${arg_FILENAME}..." message
        set(vcpkg_download_distfile_QUIET TRUE)
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

    if(NOT arg_DISABLE_ARIA2 AND _VCPKG_DOWNLOAD_TOOL STREQUAL "ARIA2" AND NOT EXISTS "${downloaded_file_path}")
        if (arg_SKIP_SHA512)
            set(OPTION_SKIP_SHA512 "SKIP_SHA512")
        endif()
        z_vcpkg_download_distfile_via_aria(
            "${OPTION_SKIP_SHA512}"
            FILENAME "${arg_FILENAME}"
            SHA512 "${arg_SHA512}"
            URLS "${arg_URLS}"
            HEADERS "${arg_HEADERS}"
        )
        set("${out_var}" "${downloaded_file_path}" PARENT_SCOPE)
        return()
    endif()

    vcpkg_list(SET urls_param)
    foreach(url IN LISTS arg_URLS)
        vcpkg_list(APPEND urls_param "--url=${url}")
    endforeach()
    if(NOT vcpkg_download_distfile_QUIET)
        message(STATUS "Downloading ${arg_URLS} -> ${arg_FILENAME}...")
    endif()

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
                --debug
                --feature-flags=-manifests # there's a bug in vcpkg x-download when it finds a manifest-root
            OUTPUT_VARIABLE output
            ERROR_VARIABLE output
            RESULT_VARIABLE error_code
            WORKING_DIRECTORY "${DOWNLOADS}"
        )

        if(NOT "${error_code}" EQUAL "0")
            message("${output}")
            z_vcpkg_download_distfile_show_proxy_and_fail("${error_code}")
        endif()
    endif()

    set("${out_var}" "${downloaded_file_path}" PARENT_SCOPE)
endfunction()
