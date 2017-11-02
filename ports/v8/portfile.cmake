include(vcpkg_common_functions)
set(VERSION 5.1.281.4)
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/v8-git-mirror-${VERSION}")

function(vcpkg_download_no_checksum URL FILENAME)
    message(STATUS "Downloading ${URL}...")
    file(DOWNLOAD ${URL} ${FILENAME} STATUS download_status)
    list(GET download_status 0 status_code)
    if (NOT "${status_code}" STREQUAL "0")
        message(STATUS "Downloading ${URL}... Failed. Status: ${download_status}")
        file(REMOVE ${FILENAME})
        set(download_success 0)
    else()
        message(STATUS "Downloading ${URL}... OK")
        set(download_success 1)
        break()
    endif()
endfunction()

function(vcpkg_from_googlesource OUT_SOURCE_PATH REPO REF)
    set(FILENAME "${REPO}-${REF}.tar.gz")    
    vcpkg_download_no_checksum(
        "https://chromium.googlesource.com/${REPO}/+archive/${REF}.tar.gz"
        ${FILENAME}
    )
    vcpkg_extract_source_archive(${FILENAME})
endfunction()

# vcpkg_from_github(
#     OUT_SOURCE_PATH SOURCE_PATH
#    REPO v8/v8-git-mirror
#    REF ${VERSION}
#    SHA512  d80035a8b35e78ee05df510a56e4ce5880e40b156f6db726daa8b9288df2db1dea14e74487ca476d06ef7d3a9d4f018ace335bc5d6c3d75a6a4437f521663d69
#    HEAD_REF master
#)
  
vcpkg_from_googlesource(
    "build/gyp"
    "external/gyp"
    "4ec6c4e3a94bd04a6da2858163d40b2429b8aad1"
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
