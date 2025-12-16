set(program_name jom)
set(program_version_string 1_1_5)
if(CMAKE_HOST_WIN32)
    set(download_urls
        "https://download.qt.io/official_releases/jom/jom_${program_version_string}.zip"
        "https://mirrors.ocf.berkeley.edu/qt/official_releases/jom/jom_${program_version_string}.zip"
        "https://mirrors.ukfast.co.uk/sites/qt.io/official_releases/jom/jom_${program_version_string}.zip"
    )
    set(download_filename "jom_${program_version_string}.zip")
    set(download_sha512 5e63b8cabe11c996d2d028c13978030c6c1cc1bace3f414f64c1ef6ac9174870903fa3f607226e2bc7d637e9e7fb561c03bef0a8b208a234599531b8b143c001)
    set(tool_subdirectory "jom-${program_version_string}")
    set(paths_to_search "${DOWNLOADS}/tools/jom/${tool_subdirectory}")
endif()
