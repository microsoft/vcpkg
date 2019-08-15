## # vcpkg_download_distfile
##
## Download and cache a file needed for this port.
##
## This helper should always be used instead of CMake's built-in `file(DOWNLOAD)` command.
##
## ## Usage
## ```cmake
## vcpkg_download_distfile(
##     <OUT_VARIABLE>
##     URLS <http://mainUrl> <http://mirror1>...
##     FILENAME <output.zip>
##     SHA512 <5981de...>
## )
## ```
## ## Parameters
## ### OUT_VARIABLE
## This variable will be set to the full path to the downloaded file. This can then immediately be passed in to [`vcpkg_extract_source_archive`](vcpkg_extract_source_archive.md) for sources.
##
## ### URLS
## A list of URLs to be consulted. They will be tried in order until one of the downloaded files successfully matches the SHA512 given.
##
## ### FILENAME
## The local name for the file. Files are shared between ports, so the file may need to be renamed to make it clearly attributed to this port and avoid conflicts.
##
## ### SHA512
## The expected hash for the file.
##
## If this doesn't match the downloaded version, the build will be terminated with a message describing the mismatch.
##
## ### SKIP_SHA512
## Skip SHA512 hash check for file.
##
## This switch is only valid when building with the `--head` command line flag.
##
## ### HEADERS
## A list of headers to append to the download request. This can be used for authentication during a download.
##
## Headers should be specified as "<header-name>: <header-value>".
##
## ## Notes
## The helper [`vcpkg_from_github`](vcpkg_from_github.md) should be used for downloading from GitHub projects.
##
## ## Examples
##
## * [apr](https://github.com/Microsoft/vcpkg/blob/master/ports/apr/portfile.cmake)
## * [fontconfig](https://github.com/Microsoft/vcpkg/blob/master/ports/fontconfig/portfile.cmake)
## * [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)
function(vcpkg_download_distfile VAR)
    set(options SKIP_SHA512)
    set(oneValueArgs FILENAME SHA512)
    set(multipleValuesArgs URLS HEADERS)
    cmake_parse_arguments(vcpkg_download_distfile "${options}" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})

    if(NOT DEFINED vcpkg_download_distfile_URLS)
        message(FATAL_ERROR "vcpkg_download_distfile requires a URLS argument.")
    endif()
    if(NOT DEFINED vcpkg_download_distfile_FILENAME)
        message(FATAL_ERROR "vcpkg_download_distfile requires a FILENAME argument.")
    endif()
    if(NOT _VCPKG_INTERNAL_NO_HASH_CHECK)
        if(vcpkg_download_distfile_SKIP_SHA512 AND NOT VCPKG_USE_HEAD_VERSION)
            message(FATAL_ERROR "vcpkg_download_distfile only allows SKIP_SHA512 when building with --head")
        endif()
        if(NOT vcpkg_download_distfile_SKIP_SHA512 AND NOT DEFINED vcpkg_download_distfile_SHA512)
            message(FATAL_ERROR "vcpkg_download_distfile requires a SHA512 argument. If you do not know the SHA512, add it as 'SHA512 0' and re-run this command.")
        endif()
        if(vcpkg_download_distfile_SKIP_SHA512 AND DEFINED vcpkg_download_distfile_SHA512)
            message(FATAL_ERROR "vcpkg_download_distfile must not be passed both SHA512 and SKIP_SHA512.")
        endif()
    endif()

    set(downloaded_file_path ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME})
    set(download_file_path_part "${DOWNLOADS}/temp/${vcpkg_download_distfile_FILENAME}")

    # Works around issue #3399
    if(IS_DIRECTORY "${DOWNLOADS}/temp")
        file(REMOVE_RECURSE "${DOWNLOADS}/temp0")
        file(RENAME "${DOWNLOADS}/temp" "${DOWNLOADS}/temp0")
        file(REMOVE_RECURSE "${DOWNLOADS}/temp0")
    endif()
    file(MAKE_DIRECTORY "${DOWNLOADS}/temp")

    function(test_hash FILE_PATH FILE_KIND CUSTOM_ERROR_ADVICE)
        if(_VCPKG_INTERNAL_NO_HASH_CHECK)
            # When using the internal hash skip, do not output an explicit message.
            return()
        endif()
        if(vcpkg_download_distfile_SKIP_SHA512)
            message(STATUS "Skipping hash check for ${FILE_PATH}.")
            return()
        endif()

        file(SHA512 ${FILE_PATH} FILE_HASH)
        if(NOT FILE_HASH STREQUAL vcpkg_download_distfile_SHA512)
            message(FATAL_ERROR
                "\nFile does not have expected hash:\n"
                "        File path: [ ${FILE_PATH} ]\n"
                "    Expected hash: [ ${vcpkg_download_distfile_SHA512} ]\n"
                "      Actual hash: [ ${FILE_HASH} ]\n"
                "${CUSTOM_ERROR_ADVICE}\n")
        endif()
    endfunction()

    if(EXISTS "${downloaded_file_path}")
        message(STATUS "Using cached ${downloaded_file_path}")
        test_hash("${downloaded_file_path}" "cached file" "Please delete the file and retry if this file should be downloaded again.")
    else()
        if(_VCPKG_NO_DOWNLOADS)
            message(FATAL_ERROR "Downloads are disabled, but '${downloaded_file_path}' does not exist.")
        endif()

        # Tries to download the file.
        list(GET vcpkg_download_distfile_URLS 0 SAMPLE_URL)
        if(_VCPKG_DOWNLOAD_TOOL STREQUAL "ARIA2" AND NOT SAMPLE_URL MATCHES "aria2")
            vcpkg_find_acquire_program("ARIA2")
            message(STATUS "Downloading ${vcpkg_download_distfile_FILENAME}...")
            if(vcpkg_download_distfile_HEADERS)
                foreach(header ${vcpkg_download_distfile_HEADERS})
                    list(APPEND request_headers "--header=${header}")
                endforeach()
            endif()
            execute_process(
                COMMAND ${ARIA2} ${vcpkg_download_distfile_URLS}
                -o temp/${vcpkg_download_distfile_FILENAME}
                -l download-${vcpkg_download_distfile_FILENAME}-detailed.log
                ${request_headers}
                OUTPUT_FILE download-${vcpkg_download_distfile_FILENAME}-out.log
                ERROR_FILE download-${vcpkg_download_distfile_FILENAME}-err.log
                RESULT_VARIABLE error_code
                WORKING_DIRECTORY ${DOWNLOADS}
            )
            if (NOT "${error_code}" STREQUAL "0")
                message(STATUS
                    "Downloading ${vcpkg_download_distfile_FILENAME}... Failed.\n"
                    "    Exit Code: ${error_code}\n"
                    "    See logs for more information:\n"
                    "        ${DOWNLOADS}/download-${vcpkg_download_distfile_FILENAME}-out.log\n"
                    "        ${DOWNLOADS}/download-${vcpkg_download_distfile_FILENAME}-err.log\n"
                    "        ${DOWNLOADS}/download-${vcpkg_download_distfile_FILENAME}-detailed.log\n"
                )
                set(download_success 0)
            else()
                file(REMOVE
                    ${DOWNLOADS}/download-${vcpkg_download_distfile_FILENAME}-out.log
                    ${DOWNLOADS}/download-${vcpkg_download_distfile_FILENAME}-err.log
                    ${DOWNLOADS}/download-${vcpkg_download_distfile_FILENAME}-detailed.log
                )
                set(download_success 1)
            endif()
        else()
            foreach(url IN LISTS vcpkg_download_distfile_URLS)
                message(STATUS "Downloading ${url}...")
                if(vcpkg_download_distfile_HEADERS)
                    foreach(header ${vcpkg_download_distfile_HEADERS})
                        list(APPEND request_headers HTTPHEADER ${header})
                    endforeach()
                endif()
                file(DOWNLOAD ${url} "${download_file_path_part}" STATUS download_status ${request_headers})
                list(GET download_status 0 status_code)
                if (NOT "${status_code}" STREQUAL "0")
                    message(STATUS "Downloading ${url}... Failed. Status: ${download_status}")
                    set(download_success 0)
                else()
                    set(download_success 1)
                    break()
                endif()
            endforeach(url)
        endif()

        if (NOT download_success)
            message(FATAL_ERROR
            "    \n"
            "    Failed to download file.\n"
            "    If you use a proxy, please set the HTTPS_PROXY and HTTP_PROXY environment\n"
            "    variables to \"https://user:password@your-proxy-ip-address:port/\".\n"
            "    Otherwise, please submit an issue at https://github.com/Microsoft/vcpkg/issues\n")
        else()
            test_hash("${download_file_path_part}" "downloaded file" "The file may have been corrupted in transit. This can be caused by proxies. If you use a proxy, please set the HTTPS_PROXY and HTTP_PROXY environment variables to \"https://user:password@your-proxy-ip-address:port/\".\n")
            get_filename_component(downloaded_file_dir "${downloaded_file_path}" DIRECTORY)
            file(MAKE_DIRECTORY "${downloaded_file_dir}")
            file(RENAME ${download_file_path_part} ${downloaded_file_path})
        endif()
    endif()
    set(${VAR} ${downloaded_file_path} PARENT_SCOPE)
endfunction()
