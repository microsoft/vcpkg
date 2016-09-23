# Usage: vcpkg_download_distfile(<VAR> URL <http://...> FILENAME <output.zip> SHA512 <5981de...>)
function(vcpkg_download_distfile VAR)
    set(oneValueArgs URL FILENAME SHA512)
    cmake_parse_arguments(vcpkg_download_distfile "" "${oneValueArgs}" "" ${ARGN})

    if(EXISTS ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME})
        message(STATUS "Using cached ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME}")
        file(SHA512 ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME} FILE_HASH)
        if(NOT FILE_HASH STREQUAL "${vcpkg_download_distfile_SHA512}")
            message(FATAL_ERROR
                "File does not have expected hash: ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME}\n"
                "    '${FILE_HASH}' <> '${vcpkg_download_distfile_SHA512}'\n"
                "Please delete the file and try again if this file should be downloaded again.")
        endif()
    else()
        message(STATUS "Downloading ${vcpkg_download_distfile_URL}")
        file(DOWNLOAD ${vcpkg_download_distfile_URL} ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME} EXPECTED_HASH SHA512=${vcpkg_download_distfile_SHA512})
    endif()
    set(${VAR} ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME} PARENT_SCOPE)
endfunction()
