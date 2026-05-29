set(program_name nasm)
set(program_version 3.01)
set(brew_package_name "nasm")
set(apt_package_name "nasm")
if(CMAKE_HOST_WIN32)
    set(download_urls
        "https://www.nasm.us/pub/nasm/releasebuilds/${program_version}/win64/nasm-${program_version}-win64.zip"
		"https://www.nasm.dev/pub/nasm/releasebuilds/${program_version}/win64/nasm-${program_version}-win64.zip"
        "https://vcpkg.github.io/assets/nasm/nasm-${program_version}-win64.zip"
    )
    set(download_filename "nasm-${program_version}-win64.zip")
    set(download_sha512 771c238ddb17c98d5736ccaba4ade1d1601d896f09e588489cb43a4f6381bc0ae14d1869f5316fe94f847f54867e65cf12665529b1e7ad88e5e7d3e162719a4f)
    set(paths_to_search "${DOWNLOADS}/tools/nasm/nasm-${program_version}")
endif()
