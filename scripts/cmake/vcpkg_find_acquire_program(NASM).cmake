set(program_name nasm)
set(program_version 2.16.03)
set(brew_package_name "nasm")
set(apt_package_name "nasm")
if(CMAKE_HOST_WIN32)
    set(download_urls
        "https://www.nasm.us/pub/nasm/releasebuilds/${program_version}/win64/nasm-${program_version}-win64.zip"
        "https://vcpkg.github.io/assets/nasm/nasm-${program_version}-win64.zip"
    )
    set(download_filename "nasm-${program_version}-win64.zip")
    set(download_sha512 22869ceb70ea0e6597fe06abe205b5d5dd66b41fe54dda73d338c488ba6ef13a39158f25b357616bf578752bb112869ef26ad897eb29352e85cf1ecc61a7c07a)
    set(paths_to_search "${DOWNLOADS}/tools/nasm/nasm-${program_version}")
endif()
