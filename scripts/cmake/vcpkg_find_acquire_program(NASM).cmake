set(program_name nasm)
set(program_version 2.16.01)
set(brew_package_name "nasm")
set(apt_package_name "nasm")
if(CMAKE_HOST_WIN32)
    set(download_urls
        "https://www.nasm.us/pub/nasm/releasebuilds/${program_version}/win64/nasm-${program_version}-win64.zip"
        "https://gstreamer.freedesktop.org/src/mirror/nasm-${program_version}-win64.zip"
    )
    set(download_filename "nasm-${program_version}-win64.zip")
    set(download_sha512 ce4d02f530dc3376b4513f219bbcec128ee5bebd8a5c332599b48d8071f803d1538d7258fec7c2e9b4d725b8d7314cea2696289d0493017eb13bfe70e5cb5062)
    set(paths_to_search "${DOWNLOADS}/tools/nasm/nasm-${program_version}")
endif()
