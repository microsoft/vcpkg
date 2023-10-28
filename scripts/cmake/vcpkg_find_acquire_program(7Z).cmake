set(program_name 7z)
set(tool_subdirectory "23.01")
set(paths_to_search "${DOWNLOADS}/tools/7zip_msi-${tool_subdirectory}-windows/Files/7-Zip") # vcpkg fetch 7zip_msi path
list(APPEND paths_to_search "${DOWNLOADS}/tools/7z/${tool_subdirectory}/Files/7-Zip")
set(download_urls "https://7-zip.org/a/7z2301.msi")
set(download_filename "7z2301.msi")
set(download_sha512 002c8ab30be802fa5fa90896d2bdf710bfbd89e39487af25af9d63821986e6d11c42b1c4f4acc79d325719b10193cd31c38f648403ef16f0580609afa8da9596)
