include(vcpkg_common_functions)
set(VERSION 5.1.281.4)
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/v8-${VERSION}")

function(vcpkg_from_googlesource OUT_SOURCE_PATH REPO REF SHA512)
    set(FILENAME "${REPO}-${REF}.tar.gz")    
    vcpkg_download_distfile(ARCHIVE
        URLS "https://chromium.googlesource.com/${REPO}/+archive/${REF}.tar.gz"
        FILENAME ${FILENAME}
        SHA512 ${SHA512}
    )
    vcpkg_extract_source_archive(${FILENAME})
endfunction()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO v8/v8-git-mirror
    REF ${VERSION}
    SHA512  b4ffe20f3e54856fcff2f946dc01fd8663c9e83364e809c2fd422e22a778daab312cfb29be336c7747603ec18f3f119caa88b1eecc2198633db68b470d12278b
    HEAD_REF master
)
  
vcpkg_from_googlesource(
    "build/gyp"
    "external/gyp"
    "4ec6c4e3a94bd04a6da2858163d40b2429b8aad1"
    ""
)
 
vcpkg_from_googlesource(
    "third_party/icu"
    "chromium/deps/icu"
    "c291cde264469b20ca969ce8832088acb21e0c48"
    ""
) 

vcpkg_from_googlesource(
    "buildtools"
    "chromium/buildtools"
    "80b5126f91be4eb359248d28696746ef09d5be67"
    ""
) 

vcpkg_from_googlesource(
    "base/trace_event/common"
    "chromium/src/base/trace_event/common"
    "c8c8665c2deaf1cc749d9f8e153256d4f67bf1b8"
    ""
)

vcpkg_from_googlesource(
    "tools/swarming_client"
    "external/swarming.client"
    "df6e95e7669883c8fe9ef956c69a544154701a49"
    ""
)

vcpkg_from_googlesource(
    "testing/gtest"
    "external/github.com/google/googletest"
    "6f8a66431cb592dad629028a50b3dd418a408c87"
    ""
)

vcpkg_from_googlesource(
    "testing/gmock"
    "external/googlemock"
    "0421b6f358139f02e102c9c332ce19a33faf75be"
    ""
)

vcpkg_from_googlesource(
    "tools/clang"
    "chromium/src/tools/clang"
    "faee82e064e04e5cbf60cc7327e7a81d2a4557ad"
    ""
)  
