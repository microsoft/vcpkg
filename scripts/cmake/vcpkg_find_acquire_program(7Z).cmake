set(program_name 7z)
if(CMAKE_HOST_WIN32)
    set(paths_to_search "${DOWNLOADS}/tools/7zip_msi-${tool_subdirectory}-windows/Files/7-Zip") # vcpkg fetch 7zip_msi path
    list(APPEND paths_to_search "${DOWNLOADS}/tools/7z/${tool_subdirectory}/Files/7-Zip")
    set(download_urls "https://github.com/ip7z/7zip/releases/download/24.09/7z2409.msi" "https://7-zip.org/a/7z2409.msi")
    set(download_filename "7z2409.msi")
    set(download_sha512 33448cc4edb2550f1fe6c4bac27c6f8d3e0d1985f7c6abcf34ac83dff650fb90b926f65a4553da4e92868f507de4dfad87e5a38b3ed8c68668b983105bb39224)
endif()
