set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(program GN)
set(search_names gn gn.exe)
set(paths_to_search "${CURRENT_PACKAGES_DIR}/tools/gn")

set(cipd_download_gn "https://chrome-infra-packages.appspot.com/dl/gn/gn")
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    EXEC_PROGRAM(uname ARGS -m OUTPUT_VARIABLE HOST_ARCH OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(HOST_ARCH STREQUAL "aarch64")
        set(program_version "3bH3TSyghUqRj8To2aE9yy4D_k_zCkymWkbwzaeEk34C")
        set(gn_platform "linux-arm64")
        set(download_sha512 "36604e7ca146f21a80c9a2463dcf09caa0c03c05507d93497884cb28da3582b9a695008d01be814e523e4a4982300ee7c717c2aa7fddbc8156736ec6b4251f9c")
    else()
        set(program_version "5v1Aw5ofON_P9Ds3nj1TzasiNIkS9eebfC3xe1lgCakC")
        set(gn_platform "linux-amd64")
        set(download_sha512 "325d9066e3c5f4e18b5489aaa060ea89f384d00ddc3d87fa329c455097c1b28f67f6e3baee2eaa54cd7f6c463cee3a4d473d0e69cd3390be91af91cbec347db1")
    endif()
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    set(supported_on_unix ON)
    EXEC_PROGRAM(uname ARGS -m OUTPUT_VARIABLE HOST_ARCH OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(HOST_ARCH STREQUAL "arm64")
        set(program_version "K29J_UnVaLzu0yYgA1orjyvrHXdkxoOSIPPPqZxN1IcC")
        set(gn_platform "mac-arm64")
        set(download_sha512 "5f8529eacf4ccd55de1060ade9da39145750516f983aaa1a53ebd6036565d0b638480327366f42c47a6eb3471c95842de0a2623c647f1a0d93cedd0907729208")
    else()
        set(program_version "oz5BCDwbV-uvEuigRPInDwZGFUGCTGFlCZBBn1AuZaQC")
        set(gn_platform "mac-amd64")
        set(download_sha512 "2f48b0f1f091e3ee424da4beb800a68f5d84b6b31ee633f3a32324508c2b96ecd2dcf0908353331eb100d11e2b1c6cfe7961cf53811de8f9951e36e88aff5272")
    endif()
else()
    set(program_version "gHozLqIHcmwMq96qzOqcgcOOK2XXE-W4nXQcchHFqKYC")
    set(gn_platform "windows-amd64")
    set(download_sha512 "2f471d4fa5f56cd72c43c5f2824f37a1baff3f26cd6c1ed43fe106153d0e654a4fb1460b01794ca3dae3104dfade81420fe1da04473e782eebab47909c9a566b")
endif()

set(download_urls "${cipd_download_gn}/${gn_platform}/+/${program_version}")
set(download_filename "gn-${gn_platform}.zip")
vcpkg_download_distfile(archive_path
    URLS ${download_urls}
    SHA512 "${download_sha512}"
    FILENAME "${download_filename}"
)
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/gn")
vcpkg_execute_in_download_mode(
    COMMAND "${CMAKE_COMMAND}" -E tar xzf "${archive_path}"
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/gn"
)

z_vcpkg_find_acquire_program_find_internal("${program}"
    PATHS ${paths_to_search}
    NAMES ${search_names}
)

message(STATUS "Using gn: ${GN}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/gn/version.txt" "${program_version}") # For vcpkg_find_acquire_program
