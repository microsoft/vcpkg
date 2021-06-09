#[===[.md:
# vcpkg_download_distfile

Download and cache a file needed for this port.

This helper should always be used instead of CMake's built-in `file(DOWNLOAD)` command.

## Usage
```cmake
vcpkg_download_distfile(
    <OUT_VARIABLE>
    URLS <http://mainUrl> <http://mirror1>...
    FILENAME <output.zip>
    SHA512 <5981de...>
    [ALWAYS_REDOWNLOAD]
)
```
## Parameters
### OUT_VARIABLE
This variable will be set to the full path to the downloaded file. This can then immediately be passed in to [`vcpkg_extract_source_archive`](vcpkg_extract_source_archive.md) for sources.

### URLS
A list of URLs to be consulted. They will be tried in order until one of the downloaded files successfully matches the SHA512 given.

### FILENAME
The local name for the file. Files are shared between ports, so the file may need to be renamed to make it clearly attributed to this port and avoid conflicts.

### SHA512
The expected hash for the file.

If this doesn't match the downloaded version, the build will be terminated with a message describing the mismatch.

### QUIET
Suppress output on cache hit

### SKIP_SHA512
Skip SHA512 hash check for file.

This switch is only valid when building with the `--head` command line flag.

### ALWAYS_REDOWNLOAD
Avoid caching; this is a REST call or otherwise unstable.

Requires `SKIP_SHA512`.

### HEADERS
A list of headers to append to the download request. This can be used for authentication during a download.

Headers should be specified as "<header-name>: <header-value>".

## Notes
The helper [`vcpkg_from_github`](vcpkg_from_github.md) should be used for downloading from GitHub projects.

## Examples

* [apr](https://github.com/Microsoft/vcpkg/blob/master/ports/apr/portfile.cmake)
* [fontconfig](https://github.com/Microsoft/vcpkg/blob/master/ports/fontconfig/portfile.cmake)
* [freetype](https://github.com/Microsoft/vcpkg/blob/master/ports/freetype/portfile.cmake)
#]===]

include(vcpkg_execute_in_download_mode)

function(vcpkg_download_distfile VAR)
    set(options SKIP_SHA512 SILENT_EXIT QUIET ALWAYS_REDOWNLOAD)
    set(oneValueArgs FILENAME SHA512)
    set(multipleValuesArgs URLS HEADERS)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 1 vcpkg_download_distfile "${options}" "${oneValueArgs}" "${multipleValuesArgs}")

    if(NOT DEFINED vcpkg_download_distfile_URLS)
        message(FATAL_ERROR "vcpkg_download_distfile requires a URLS argument.")
    endif()
    if(NOT DEFINED vcpkg_download_distfile_FILENAME)
        message(FATAL_ERROR "vcpkg_download_distfile requires a FILENAME argument.")
    endif()
    if(vcpkg_download_distfile_SILENT_EXIT)
        message(WARNING "SILENT_EXIT has been deprecated as an argument to vcpkg_download_distfile -- remove the argument to resolve this warning")
    endif()
    if(vcpkg_download_distfile_ALWAYS_REDOWNLOAD AND NOT vcpkg_download_distfile_SKIP_SHA512)
        message(FATAL_ERROR "ALWAYS_REDOWNLOAD option requires SKIP_SHA512 as well")
    endif()
    if(_VCPKG_INTERNAL_NO_HASH_CHECK)
        set(vcpkg_download_distfile_SKIP_SHA512 1)
    else()
        if(NOT vcpkg_download_distfile_SKIP_SHA512 AND NOT DEFINED vcpkg_download_distfile_SHA512)
            message(FATAL_ERROR "vcpkg_download_distfile requires a SHA512 argument. If you do not know the SHA512, add it as 'SHA512 0' and re-run this command.")
        endif()
        if(vcpkg_download_distfile_SKIP_SHA512 AND DEFINED vcpkg_download_distfile_SHA512)
            message(FATAL_ERROR "vcpkg_download_distfile must not be passed both SHA512 and SKIP_SHA512.")
        endif()
    endif()
    if(NOT vcpkg_download_distfile_SKIP_SHA512)
        if(vcpkg_download_distfile_SHA512 STREQUAL "0")
            string(REPEAT "0" 128 vcpkg_download_distfile_SHA512)
        endif()
        string(LENGTH "${vcpkg_download_distfile_SHA512}" vcpkg_download_distfile_SHA512_length)
        if(NOT vcpkg_download_distfile_SHA512_length EQUAL "128")
            message(FATAL_ERROR "Invalid SHA512: ${vcpkg_download_distfile_SHA512}. If you do not know the file's SHA512, set this to \"0\".")
        endif()
    endif()

    set(downloaded_file_path ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME})
    set(download_file_path_part "${DOWNLOADS}/temp/${vcpkg_download_distfile_FILENAME}")

    # Works around issue #3399
    if(IS_DIRECTORY "${DOWNLOADS}/temp")
        # Delete "temp0" directory created by the old version of vcpkg
        file(REMOVE_RECURSE "${DOWNLOADS}/temp0")

        file(GLOB temp_files "${DOWNLOADS}/temp")
        file(REMOVE_RECURSE ${temp_files})
    else()
      file(MAKE_DIRECTORY "${DOWNLOADS}/temp")
    endif()

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

    # vcpkg_download_distfile_ALWAYS_REDOWNLOAD only triggers when NOT _VCPKG_NO_DOWNLOADS
    # this could be de-morgan'd out but it's more clear this way
    if(EXISTS "${downloaded_file_path}" AND NOT (vcpkg_download_distfile_ALWAYS_REDOWNLOAD AND NOT _VCPKG_NO_DOWNLOADS))
        if(NOT vcpkg_download_distfile_QUIET)
            message(STATUS "Using ${downloaded_file_path}")
        endif()
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
                foreach(header IN LISTS vcpkg_download_distfile_HEADERS)
                    list(APPEND request_headers "--header=${header}")
                endforeach()
            endif()
            vcpkg_execute_in_download_mode(
                COMMAND ${ARIA2} ${vcpkg_download_distfile_URLS}
                -o temp/${vcpkg_download_distfile_FILENAME}
                -l download-${vcpkg_download_distfile_FILENAME}-detailed.log
                ${request_headers}
                OUTPUT_FILE download-${vcpkg_download_distfile_FILENAME}-out.log
                ERROR_FILE download-${vcpkg_download_distfile_FILENAME}-err.log
                RESULT_VARIABLE error_code
                WORKING_DIRECTORY "${DOWNLOADS}"
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
                test_hash("${DOWNLOADS}/temp/${vcpkg_download_distfile_FILENAME}" "downloaded file" "The file may have been corrupted in transit.")
                file(REMOVE
                    ${DOWNLOADS}/download-${vcpkg_download_distfile_FILENAME}-out.log
                    ${DOWNLOADS}/download-${vcpkg_download_distfile_FILENAME}-err.log
                    ${DOWNLOADS}/download-${vcpkg_download_distfile_FILENAME}-detailed.log
                )
                get_filename_component(downloaded_file_dir "${downloaded_file_path}" DIRECTORY)
                file(MAKE_DIRECTORY "${downloaded_file_dir}")
                file(RENAME "${DOWNLOADS}/temp/${vcpkg_download_distfile_FILENAME}" "${downloaded_file_path}")
                set(download_success 1)
            endif()
        elseif(vcpkg_download_distfile_SKIP_SHA512 OR vcpkg_download_distfile_HEADERS)
            # This is a workaround until the vcpkg tool supports downloading files without SHA512 and with headers
            set(download_success 0)
            set(request_headers)
            if(vcpkg_download_distfile_HEADERS)
                foreach(header IN LISTS vcpkg_download_distfile_HEADERS)
                    list(APPEND request_headers HTTPHEADER ${header})
                endforeach()
            endif()
            foreach(url IN LISTS vcpkg_download_distfile_URLS)
                message(STATUS "Downloading ${url} -> ${vcpkg_download_distfile_FILENAME}...")
                file(DOWNLOAD "${url}" "${download_file_path_part}" STATUS download_status ${request_headers})
                list(GET download_status 0 status_code)
                if (NOT "${status_code}" STREQUAL "0")
                    message(STATUS "Downloading ${url}... Failed. Status: ${download_status}")
                else()
                    test_hash("${download_file_path_part}" "downloaded file" "The file may have been corrupted in transit. This can be caused by proxies. If you use a proxy, please set the HTTPS_PROXY and HTTP_PROXY environment variables to \"https://user:password@your-proxy-ip-address:port/\".\n")
                    get_filename_component(downloaded_file_dir "${downloaded_file_path}" DIRECTORY)
                    file(MAKE_DIRECTORY "${downloaded_file_dir}")
                    file(RENAME ${download_file_path_part} ${downloaded_file_path})
                    set(download_success 1)
                    break()
                endif()
            endforeach(url)
        else()
            set(urls)
            foreach(url IN LISTS vcpkg_download_distfile_URLS)
                list(APPEND urls "--url=${url}")
            endforeach()
            if(NOT vcpkg_download_distfile_QUIET)
                message(STATUS "Downloading ${vcpkg_download_distfile_URLS} -> ${vcpkg_download_distfile_FILENAME}...")
            endif()
            set(request_headers)
            if(vcpkg_download_distfile_HEADERS)
                foreach(header IN LISTS vcpkg_download_distfile_HEADERS)
                    list(APPEND request_headers "--header=${header}")
                endforeach()
            endif()
            vcpkg_execute_in_download_mode(
                COMMAND "$ENV{VCPKG_COMMAND}" x-download
                    "${downloaded_file_path}"
                    "${vcpkg_download_distfile_SHA512}"
                    ${urls}
                    ${request_headers}
                    --debug
                    --feature-flags=-manifests # there's a bug in vcpkg x-download when it finds a manifest-root
                OUTPUT_VARIABLE output
                ERROR_VARIABLE output
                RESULT_VARIABLE failure
                WORKING_DIRECTORY "${DOWNLOADS}"
            )
            if(failure)
                message("${output}")
                set(download_success 0)
            else()
                set(download_success 1)
            endif()
        endif()

        if(NOT download_success)
            message(FATAL_ERROR
                "    \n"
                "    Failed to download file.\n"  
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
                "    3. You proxy's remote server is out of service.\n"
                "    \n"
                "    In future vcpkg releases, if you are using Windows, you no longer need to set\n"
                "    HTTP(S)_PROXY environment variables. Vcpkg will simply apply Windows IE Proxy\n"
                "    Settings set by your proxy software. See (https://github.com/microsoft/vcpkg-tool/pull/49)\n"
                "    and (https://github.com/microsoft/vcpkg-tool/pull/77)\n"
                "    \n"
                "    Otherwise, please submit an issue at https://github.com/Microsoft/vcpkg/issues\n")
        endif()
    endif()
    set(${VAR} ${downloaded_file_path} PARENT_SCOPE)
endfunction()
