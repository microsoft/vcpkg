set(program_name jom)
set(program_version_string 1_1_7)
if(CMAKE_HOST_WIN32)
    set(download_urls
        "https://download.qt.io/official_releases/jom/jom_${program_version_string}.zip"
        "https://mirrors.ocf.berkeley.edu/qt/official_releases/jom/jom_${program_version_string}.zip"
        "https://mirrors.ukfast.co.uk/sites/qt.io/official_releases/jom/jom_${program_version_string}.zip"
    )
    set(download_filename "jom_${program_version_string}.zip")
    set(download_sha512 f48ffee06d10012100adf7bf89059a5fee17d97a7f7cb25d0e216be939c366f26014688107d9ed4ce43845a2bea2601d22813df462358c87449723e297f14677)
    set(tool_subdirectory "jom-${program_version_string}")
    set(paths_to_search "${DOWNLOADS}/tools/jom/${tool_subdirectory}")
endif()
