set(program_name 7z)
if(CMAKE_HOST_WIN32)
    set(tool_subdirectory "24.06")
    set(paths_to_search "${DOWNLOADS}/tools/7zip_msi-${tool_subdirectory}-windows/Files/7-Zip") # vcpkg fetch 7zip_msi path
    list(APPEND paths_to_search "${DOWNLOADS}/tools/7z/${tool_subdirectory}/Files/7-Zip")
    set(download_urls "https://github.com/ip7z/7zip/releases/download/24.06/7z2406.msi" "https://7-zip.org/a/7z2406.msi")
    set(download_filename "7z2406.msi")
    set(download_sha512 44cac24b4fb9972680e99adfe7cc99baff972007a5803b01e0c96388412456c333ce6f38990673e9338f4af35c0630db6d1cf116eda9895cb2b8d60ed287787f)
endif()
