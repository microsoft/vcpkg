set(program_name jom)
set(program_version_string 1_1_6)
if(CMAKE_HOST_WIN32)
    set(download_urls
        "https://download.qt.io/official_releases/jom/jom_${program_version_string}.zip"
        "https://mirrors.ocf.berkeley.edu/qt/official_releases/jom/jom_${program_version_string}.zip"
        "https://mirrors.ukfast.co.uk/sites/qt.io/official_releases/jom/jom_${program_version_string}.zip"
    )
    set(download_filename "jom_${program_version_string}.zip")
    set(download_sha512 6fd99ad144e715cfdfe222b3999edcec0e1b82cfe216d79fedfd404942c56cfdd1827e445b8f7112148f75c02802d345f4b435321fc1530ac4b46e77bb9909b3)
    set(tool_subdirectory "jom-${program_version_string}")
    set(paths_to_search "${DOWNLOADS}/tools/jom/${tool_subdirectory}")
endif()
