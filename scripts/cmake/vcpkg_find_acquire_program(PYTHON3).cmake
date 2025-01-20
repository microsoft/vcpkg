if(CMAKE_HOST_WIN32)
    set(program_name python)
    set(program_version 3.12.7)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(build_arch $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(build_arch $ENV{PROCESSOR_ARCHITECTURE})
    endif()
    if(build_arch MATCHES "^(ARM|arm)64$")
        set(tool_subdirectory "python-${program_version}-arm64")
        # https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-arm64.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-arm64.zip")
        set(download_filename "python-${program_version}-embed-arm64.zip")
        set(download_sha512 D1D1183682D20AC057C45BF2AD264B6568CDEB54A1502823C76A2448386CAEF79A3AB9EA8FF57A5C023D432590FCCB5E3E9980F8760CD9BAAC5A2A82BA240D73)
    elseif(build_arch MATCHES "(amd|AMD)64")
        set(tool_subdirectory "python-${program_version}-x64")
        # https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-amd64.zip")
        set(download_filename "python-${program_version}-embed-amd64.zip")
        set(download_sha512 2F67A8487A9EDECE26B73AAB27E75249E538938AD976D371A9411B54DBAE20AFEAC82B406AD4EEEE38B1CF6F407E7620679D30C0FFF82EC8E8AE62268C322D59)
    else()
        set(tool_subdirectory "python-${program_version}-x86")
        # https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-win32.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-win32.zip")
        set(download_filename "python-${program_version}-embed-win32.zip")
        set(download_sha512 15542080E0CC25C574391218107FE843006E8C5A7161D1CD48CF14A3C47155C0244587273D9C747F35B15EA17676869ECCE079214824214C1A62ABFC86AD9F9B)
    endif()

    # Remove this after the next update
    string(APPEND tool_subdirectory "-1")

    set(paths_to_search "${DOWNLOADS}/tools/python/${tool_subdirectory}")

    vcpkg_list(SET post_install_command
        "${CMAKE_COMMAND}" "-DPYTHON_DIR=${paths_to_search}" "-DPYTHON_VERSION=${program_version}" -P "${CMAKE_CURRENT_LIST_DIR}/z_vcpkg_make_python_less_embedded.cmake"
    )
else()
    set(program_name python3)
    set(brew_package_name "python")
    set(apt_package_name "python3")
endif()
