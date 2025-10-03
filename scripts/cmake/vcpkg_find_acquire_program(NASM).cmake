set(program_name nasm)
set(program_version 3.00)
set(brew_package_name "nasm")
set(apt_package_name "nasm")
if(CMAKE_HOST_WIN32)
    set(download_urls
        "https://www.nasm.us/pub/nasm/releasebuilds/${program_version}/win64/nasm-${program_version}-win64.zip"
		"https://www.nasm.dev/pub/nasm/releasebuilds/${program_version}/win64/nasm-${program_version}-win64.zip"
        "https://vcpkg.github.io/assets/nasm/nasm-${program_version}-win64.zip"
    )
    set(download_filename "nasm-${program_version}-win64.zip")
    set(download_sha512 d8ea80a47e9a82dcfbdf31f24d379f318cd2d722cfbfc3821d8f157ba3d4f6838f1d95518d8d81d7d3d51179093f5135d7ce046c20ecb2c2ad4dc8b664951dc8)
    set(paths_to_search "${DOWNLOADS}/tools/nasm/nasm-${program_version}")
endif()
