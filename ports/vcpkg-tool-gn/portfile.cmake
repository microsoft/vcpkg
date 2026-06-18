set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(program GN)
set(search_names gn gn.exe)
set(paths_to_search "${CURRENT_PACKAGES_DIR}/tools/gn")

set(cipd_download_gn "https://chrome-infra-packages.appspot.com/dl/gn/gn")
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    EXEC_PROGRAM(uname ARGS -m OUTPUT_VARIABLE HOST_ARCH OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(HOST_ARCH STREQUAL "aarch64")
        set(program_version "VAlW-kLtoSKXRPMM4ecwRVPmARjjo84zFmOVyy7Gq2AC")
        set(gn_platform "linux-arm64")
        set(download_sha512 "b16809f951774a6c36ec183a0214f957af289bc2ca015d425200f99f7a40c9ed27973056df4742c636c5cf2e1a2741b9fa4793ea2c6fcb01c42b17996a2464b9")
    elseif(HOST_ARCH STREQUAL "riscv64")
        set(program_version "tauFErkaMkGZN-_03F9DJfMm3DRnaiGOS6SXeLcOswAC")
        set(gn_platform "linux-riscv64")
        set(download_sha512 "210de22ad5d5634be902c68c6deed08686e252c34218baf30c6bd7266be142740b18d7e6a27b0ef56eb6f75dc5255d5365dff0b98ade482ccba4a32e756a14e5")
    else()
        set(program_version "fj2NZKMkIYZNH6uYG0bn8OsW_lZB5JKz3JeScMCLAGQC")
        set(gn_platform "linux-amd64")
        set(download_sha512 "d49575bd383b6aace1257a6e9439ce0a206173ec2cab94d5312f06db412e09c89aa75b1f4c69f5dca4389d15a489c211a73439a66f437c34b18bc90eefa0b775")
    endif()
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    set(supported_on_unix ON)
    EXEC_PROGRAM(uname ARGS -m OUTPUT_VARIABLE HOST_ARCH OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(HOST_ARCH STREQUAL "arm64")
        set(program_version "CLrnEDB8EiVuryPag1tNY_qaLMLtt193LzCgLMG58mMC")
        set(gn_platform "mac-arm64")
        set(download_sha512 "e3b2bd5b2b1cb1b5a51523d03ad5b5f052e2862da8f76e492b84ae5600f1670ea014d9a37e7e0b94439d610d8caba3e87badba0f2265b2c8ea2fd72ac3529790")
    else()
        set(program_version "F-i5FFe_bOb6clj5wr3S6HLUlfG6b6TAFdvm-uLE3mYC")
        set(gn_platform "mac-amd64")
        set(download_sha512 "1f56ed53b9770919f7682b11aa8beda000d62dd5c8ace72e7c92ed1782be2cdb1c64cb62f6ac7dc5259ac446105b33aa6806dd5e9c122a8c37ba1be2c85f1dad")
    endif()
else()
    set(program_version "2lRFka6-TQLmU7YpwecZP2tJYOs9kkRN8y-8y_HWwWIC")
    set(gn_platform "windows-amd64")
    set(download_sha512 "60845024b70c52cc98ee3144a7b3889da98285033db631e53c4cbd6e036d33f4ce66b2ff85890318d54a01558410c49ee7622c24d5b1650f73e7734dd1ecc1ad")
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
