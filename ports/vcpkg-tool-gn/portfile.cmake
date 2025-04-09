set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(program GN)
set(search_names gn gn.exe)
set(paths_to_search "${CURRENT_PACKAGES_DIR}/tools/gn")

set(cipd_download_gn "https://chrome-infra-packages.appspot.com/dl/gn/gn")
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    EXEC_PROGRAM(uname ARGS -m OUTPUT_VARIABLE HOST_ARCH OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(HOST_ARCH STREQUAL "aarch64")
        set(program_version "zdEKhZQQpKV3Wun590v3-Yo84GXTUt4bFzxL5BHlGtcC")
        set(gn_platform "linux-arm64")
        set(download_sha512 "471d86275861227772cfd9da960b2177c6c66220cebb473bb7da8cc6c6930de0d10d627315e3919d8b77d3ab89f6445f4dd38b2836bf7ac1e3b87c9254fafde7")
    else()
        set(program_version "auEGIg-Lz2JEh5G6zSXGLWoSxYeO-HEu1a97-ppTwaMC")
        set(gn_platform "linux-amd64")
        set(download_sha512 "e1485ad205a152b2e3f8c1f1145a87727e7093bbe81a3a33c5dc27e509ffca9a1200af86d21984d9ad30a00173e4c2b78c91284e68f262c8108e7ab1d7ba4cd6")
    endif()
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    set(supported_on_unix ON)
    EXEC_PROGRAM(uname ARGS -m OUTPUT_VARIABLE HOST_ARCH OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(HOST_ARCH STREQUAL "arm64")
        set(program_version "xfZa4fTa4sc1YwdYOr8PaYOk3-zXhpOPJfUSe-Py0iQC")
        set(gn_platform "mac-arm64")
        set(download_sha512 "8c99dba57d0f5454151064bc8f8bc0f838edb9c486030e13f6ce313cf6585dfa28dca30ad19bed82e5ccc541d862b304299c71b6813ad8dd895b448c9807a178")
    else()
        set(program_version "qP7MMs432pngy4N16ghGMDikJcFQEIdK5FjGNQPvfbIC")
        set(gn_platform "mac-amd64")
        set(download_sha512 "16177f496fd438d032b4402ee62726961d6686339e9753dc26f703badef61d1d0bfd8f04ee05e829f4fd14f52ac0423bd8d3356e7f75f43f6e91e5812faf8408")
    endif()
else()
    set(program_version "tj_hmVJSBKakJpGcxd_Q-2Gux3NamUBj3XaY1vYPKR4C")
    set(gn_platform "windows-amd64")
    set(download_sha512 "ad584648b7a7d3e3e0c442f91eecc77205b23cd9cf2b6f4774dc6dde531473931d26d0b38860f86ae1d66c1a6765659d31af3ad7ff73354c846e67bbad0b8709")
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
