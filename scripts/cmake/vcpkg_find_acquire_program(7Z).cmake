set(program_name 7z)
if(CMAKE_HOST_WIN32)
    set(paths_to_search "${DOWNLOADS}/tools/7zip_msi-${tool_subdirectory}-windows/Files/7-Zip") # vcpkg fetch 7zip_msi path
    list(APPEND paths_to_search "${DOWNLOADS}/tools/7z/${tool_subdirectory}/Files/7-Zip")
    set(download_urls "https://github.com/ip7z/7zip/releases/download/24.09/7z2409.msi" "https://7-zip.org/a/7z2409.msi")
    set(download_filename "7z2409.msi")
    set(download_sha512 33448CC4EDB2550F1FE6C4BAC27C6F8D3E0D1985F7C6ABCF34AC83DFF650FB90B926F65A4553DA4E92868F507DE4DFAD87E5A38B3ED8C68668B983105BB39224)
endif()
