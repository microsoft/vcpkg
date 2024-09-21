set(program_name 7z)
if(CMAKE_HOST_WIN32)
    set(tool_subdirectory "24.08")
    set(paths_to_search "${DOWNLOADS}/tools/7zip_msi-${tool_subdirectory}-windows/Files/7-Zip") # vcpkg fetch 7zip_msi path
    list(APPEND paths_to_search "${DOWNLOADS}/tools/7z/${tool_subdirectory}/Files/7-Zip")
    set(download_urls "https://github.com/ip7z/7zip/releases/download/24.08/7z2408.msi" "https://7-zip.org/a/7z2408.msi")
    set(download_filename "7z2408.msi")
    set(download_sha512 0bc88c99ad921a6f828d9ed9b8391510d1d0c2f8ecb7ad2921838c97c20f215e2ab03198009d159e2d1859bb20f157010f492288ce61c86544df06742cebbc34)
endif()
