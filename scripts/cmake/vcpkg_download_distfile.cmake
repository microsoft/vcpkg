## # vcpkg_download_distfile
##
## Download and cache a file needed for this port.
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
## ## Notes
## The command [`vcpkg_from_github`](vcpkg_from_github.md) should be used instead of this for downloading the main archive for GitHub projects.
##
## ## Examples
##
## * [boost](https://github.com/Microsoft/vcpkg/blob/master/ports/boost/portfile.cmake)
## * [fontconfig](https://github.com/Microsoft/vcpkg/blob/master/ports/fontconfig/portfile.cmake)
## * [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)
function(vcpkg_download_distfile VAR)
    set(oneValueArgs FILENAME SHA512)
    set(multipleValuesArgs URLS)
    cmake_parse_arguments(vcpkg_download_distfile "" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})
    set(downloaded_file_path ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME})

    function(test_hash FILE_KIND CUSTOM_ERROR_ADVICE)
        message(STATUS "Testing integrity of ${FILE_KIND}...")
        file(SHA512 ${downloaded_file_path} FILE_HASH)
        if(NOT "${FILE_HASH}" STREQUAL "${vcpkg_download_distfile_SHA512}")
            message(FATAL_ERROR
                "\nFile does not have expected hash:\n"
                "        File path: [ ${downloaded_file_path} ]\n"
                "    Expected hash: [ ${vcpkg_download_distfile_SHA512} ]\n"
                "      Actual hash: [ ${FILE_HASH} ]\n"
                "${CUSTOM_ERROR_ADVICE}\n")
        endif()
        message(STATUS "Testing integrity of ${FILE_KIND}... OK")
    endfunction()

    if(EXISTS ${downloaded_file_path})
        message(STATUS "Using cached ${downloaded_file_path}")
        test_hash("cached file" "Please delete the file and retry if this file should be downloaded again.")
    else()
        if(_VCPKG_NO_DOWNLOADS)
            message(FATAL_ERROR "Downloads are disabled, but '${downloaded_file_path}' does not exist.")
        endif()

        # Tries to download the file.
        foreach(url IN LISTS vcpkg_download_distfile_URLS)
            message(STATUS "Downloading ${url}...")
            file(DOWNLOAD ${url} ${downloaded_file_path} STATUS download_status)
            list(GET download_status 0 status_code)
            if (NOT "${status_code}" STREQUAL "0")
                message(STATUS "Downloading ${url}... Failed. Status: ${download_status}")
                file(REMOVE ${downloaded_file_path})
                set(download_success 0)
            else()
                message(STATUS "Downloading ${url}... OK")
                set(download_success 1)
                break()
            endif()
        endforeach(url)

        if (NOT download_success)
            message(FATAL_ERROR
            "\n"
            "    Failed to download file.\n"
            "    Add mirrors or submit an issue at https://github.com/Microsoft/vcpkg/issues\n")
        else()
            test_hash("downloaded file" "The file may be corrupted.")
        endif()
    endif()
    set(${VAR} ${downloaded_file_path} PARENT_SCOPE)
endfunction()
