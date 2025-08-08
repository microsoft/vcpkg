set(program_name jom)
set(program_version_string 1_1_4)
if(CMAKE_HOST_WIN32)
    set(download_urls
        "https://download.qt.io/official_releases/jom/jom_${program_version_string}.zip"
        "https://mirrors.ocf.berkeley.edu/qt/official_releases/jom/jom_${program_version_string}.zip"
        "https://mirrors.ukfast.co.uk/sites/qt.io/official_releases/jom/jom_${program_version_string}.zip"
    )
    set(download_filename "jom_${program_version_string}.zip")
    set(download_sha512 a683bd829c84942223a791dae8abac5cfc2e3fa7de84c6fdc490ad3aa996a26c9fa0be0636890f02c9d56948bbe3225b43497cb590d1cb01e70c6fac447fa17b)
    set(tool_subdirectory "jom-${program_version_string}")
    set(paths_to_search "${DOWNLOADS}/tools/jom/${tool_subdirectory}")
endif()
