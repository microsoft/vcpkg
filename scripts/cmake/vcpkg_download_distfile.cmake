# Usage: vcpkg_download_distfile(<VAR> URL <http://...> FILENAME <output.zip> MD5 <5981de...>)
function(vcpkg_download_distfile VAR)
    set(oneValueArgs URL FILENAME MD5)
    cmake_parse_arguments(vcpkg_download_distfile "" "${oneValueArgs}" "" ${ARGN})

    if(EXISTS ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME})
        message(STATUS "Using cached ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME}")
        file(MD5 ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME} FILE_HASH)
        if(NOT FILE_HASH MATCHES ${vcpkg_download_distfile_MD5})
            message(FATAL_ERROR
                "File does not have expected hash: ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME}\n"
                "    ${FILE_HASH} <> ${vcpkg_download_distfile_MD5}\n"
                "Please delete the file and try again if this file should be downloaded again.")
        endif()
    else()
        message(STATUS "Downloading ${vcpkg_download_distfile_URL}")
        file(DOWNLOAD ${vcpkg_download_distfile_URL} ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME} EXPECTED_HASH MD5=${vcpkg_download_distfile_MD5})
    endif()
    set(${VAR} ${DOWNLOADS}/${vcpkg_download_distfile_FILENAME} PARENT_SCOPE)
endfunction()
