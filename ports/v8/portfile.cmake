include(vcpkg_common_functions)
set(VERSION 6.4.190)
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/v8-${VERSION}")

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/68b6ac7c644184ae383a6631b8090acd8df7e905"
    DESTINATION ${SOURCE_PATH}
)
file(RENAME
    "${SOURCE_PATH}/68b6ac7c644184ae383a6631b8090acd8df7e905"
    "${SOURCE_PATH}/gn.exe"
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO v8/v8
    REF ${VERSION}
    SHA512 fc54786ff1d63895638ca76aea9be73ed560fbab1a65f6efe0070472045b9673a357444e4d3ac34c975d69fad7d298fc794db17303d7188a51b033051b8bddbc
    HEAD_REF master
)

function(vcpkg_download_no_checksum URL FILENAME)
    message(STATUS "Downloading ${URL}...")
    file(REMOVE ${FILENAME})
    file(DOWNLOAD ${URL} ${FILENAME} STATUS download_status)
    list(GET download_status 0 status_code)
    if (NOT "${status_code}" STREQUAL "0")
        message(STATUS "Downloading ${URL}... Failed. Status: ${download_status}")
        file(REMOVE ${FILENAME})
        set(download_success 0)
    else()
        message(STATUS "Downloading ${URL}... OK")
        set(download_success 1)
    endif()
endfunction()

function(vcpkg_from_googlesource OUT_SOURCE_PATH REPO REF)
    set(FILENAME "${DOWNLOADS}/${REPO}/${REF}.tar.gz")    
    vcpkg_download_no_checksum(
        "https://chromium.googlesource.com/${REPO}/+archive/${REF}.tar.gz"
        ${FILENAME}
    )
    message(STATUS "Extracting to ${SOURCE_PATH}/${OUT_SOURCE_PATH}")
    vcpkg_extract_source_archive(${FILENAME} "${SOURCE_PATH}/${OUT_SOURCE_PATH}")
endfunction()

vcpkg_from_googlesource(
    "build/gn"
    "chromium/src/tools/gn"
    "93afc7c91e802e43df62c7ac2711238bc689e766"
)

vcpkg_from_googlesource(
    "third_party/icu"
    "chromium/deps/icu"
    "c291cde264469b20ca969ce8832088acb21e0c48"
) 

vcpkg_from_googlesource(
    "buildtools"
    "chromium/buildtools"
    "80b5126f91be4eb359248d28696746ef09d5be67"
) 

vcpkg_from_googlesource(
    "base/trace_event/common"
    "chromium/src/base/trace_event/common"
    "c8c8665c2deaf1cc749d9f8e153256d4f67bf1b8"
)

vcpkg_from_googlesource(
    "tools/swarming_client"
    "external/swarming.client"
    "df6e95e7669883c8fe9ef956c69a544154701a49"
)

vcpkg_from_googlesource(
    "testing/gtest"
    "external/github.com/google/googletest"
    "6f8a66431cb592dad629028a50b3dd418a408c87"
)

vcpkg_from_googlesource(
    "testing/gmock"
    "external/googlemock"
    "0421b6f358139f02e102c9c332ce19a33faf75be"
)

vcpkg_from_googlesource(
    "tools/clang"
    "chromium/src/tools/clang"
    "faee82e064e04e5cbf60cc7327e7a81d2a4557ad"
)  

execute_process(
    "gn.exe" "--help"
)


