# Usage: vcpkg_download_distfile(<VAR> URL <http://...> FILENAME <output.zip> SHA512 <5981de...> MIRRORS <http://mirror1> <http://mirror2>)
function(vcpkg_download_distfile VAR)
    set(oneValueArgs URL FILENAME SHA512)
    set(multipleValuesArgs MIRRORS)
    cmake_parse_arguments(vcpkg_download_distfile "" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})

    set(downloaded_file_path ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME})
    if(EXISTS ${downloaded_file_path})
        message(STATUS "Using cached ${downloaded_file_path}")
        file(SHA512 ${downloaded_file_path} FILE_HASH)
        if(NOT "${FILE_HASH}" STREQUAL "${vcpkg_download_distfile_SHA512}")
            message(FATAL_ERROR
                "\nFile does not have expected hash:\n"
                "        File path: [${downloaded_file_path}]\n"
                "    Expected hash: [${vcpkg_download_distfile_SHA512}]\n"
                "      Actual hash: [${FILE_HASH}]\n"
                "Please delete the file and try again if this file should be downloaded again.\n")
        endif()
    else()
        # Tries to download the file.
        list(INSERT vcpkg_download_distfile_MIRRORS 0 ${vcpkg_download_distfile_URL})
        foreach(url IN LISTS vcpkg_download_distfile_MIRRORS)
            message(STATUS "Downloading ${url}...")
            file(DOWNLOAD ${url} ${downloaded_file_path} STATUS download_status)
            list(GET download_status 0 status_code)
            if (NOT "${status_code}" STREQUAL "0")
                message(STATUS "Downloading ${url}... Failed")
                file(REMOVE ${downloaded_file_path})
                set(download_success 0)
            else()
                message(STATUS "Downloading ${url}... OK")
                set(download_success 1)
                break()
            endif()
        endforeach(url)

        if (NOT ${download_success})
            message(FATAL_ERROR
            "\n"
            "    Failed to download file.\n"
            "    Add mirrors or submit an issue at https://github.com/Microsoft/vcpkg/issues/new\n")
        else()
            message(STATUS "Testing integrity of downloaded file...")
            file(SHA512 ${downloaded_file_path} FILE_HASH)
            if(NOT "${FILE_HASH}" STREQUAL "${vcpkg_download_distfile_SHA512}")
                message(FATAL_ERROR
                    "\nFile does not have expected hash:\n"
                    "        File path: [${downloaded_file_path}]\n"
                    "    Expected hash: [${vcpkg_download_distfile_SHA512}]\n"
                    "      Actual hash: [${FILE_HASH}]\n"
                    "The file may be corrupted.\n")
            endif()
            message(STATUS "Testing integrity of downloaded file... OK")
        endif()
    endif()
    set(${VAR} ${downloaded_file_path} PARENT_SCOPE)
endfunction()
