set(program_name go)
set(tool_subdirectory 1.16.6.windows-386)
set(paths_to_search ${DOWNLOADS}/tools/go/${tool_subdirectory}/go/bin)
set(brew_package_name "go")
set(apt_package_name "golang-go")
if(CMAKE_HOST_WIN32)
    set(download_urls "https://dl.google.com/go/go${tool_subdirectory}.zip")
    set(download_filename "go${tool_subdirectory}.zip")
    set(download_sha512 2a1e539ed628c0cca5935d24d22cf3a7165f5c80e12a4003ac184deae6a6d0aa31f582f3e8257b0730adfc09aeec3a0e62f4732e658c312d5382170bcd8c94d8)
endif()
