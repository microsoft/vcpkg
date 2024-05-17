set(program_name 7z)
if(CMAKE_HOST_WIN32)
    set(tool_subdirectory "24.05")
    set(paths_to_search "${DOWNLOADS}/tools/7zip_msi-${tool_subdirectory}-windows/Files/7-Zip") # vcpkg fetch 7zip_msi path
    list(APPEND paths_to_search "${DOWNLOADS}/tools/7z/${tool_subdirectory}/Files/7-Zip")
    set(download_urls "https://github.com/ip7z/7zip/releases/download/24.05/7z2405.msi" "https://7-zip.org/a/7z2405.msi")
    set(download_filename "7z2405.msi")
    set(download_sha512 4b28c14910641f7008efe97e351f4895f7f44fdd1688a4dd578a77267120da583d1186701a7473e37b14933eca16493ac6668ed86e760fb33ce428c1fd9c210b)
endif()
