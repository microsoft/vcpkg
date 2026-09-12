if(CMAKE_HOST_WIN32)
    set(program_name python)
    set(program_version 3.14.5)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(build_arch $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(build_arch $ENV{PROCESSOR_ARCHITECTURE})
    endif()
    if(build_arch MATCHES "^(ARM|arm)64$")
        set(tool_subdirectory "python-${program_version}-arm64")
        # https://www.python.org/ftp/python/3.14.5/python-3.14.5-embed-arm64.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-arm64.zip")
        set(download_filename "python-${program_version}-embed-arm64.zip")
        set(download_sha512 fac1c50a74bd00e3f80f655d1ab2e319a97ba131ee3eaeed37248dacc3ee650561b1acf2df159d9ed984d9bd195a4f238bfea438d7bd156e5e61438073b94c90)
    elseif(build_arch MATCHES "(amd|AMD)64")
        set(tool_subdirectory "python-${program_version}-x64")
        # https://www.python.org/ftp/python/3.14.5/python-3.14.5-embed-amd64.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-amd64.zip")
        set(download_filename "python-${program_version}-embed-amd64.zip")
        set(download_sha512 c74f2c52afde12742d914740a25de5f2921474cc3d347d15ff98e9ee55d261516c291d5cc9179d9bcef370a310798ba6254685ae0a6d25a1f6acf12eac01bbde)
    else()
        set(tool_subdirectory "python-${program_version}-x86")
        # https://www.python.org/ftp/python/3.14.5/python-3.14.5-embed-win32.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-win32.zip")
        set(download_filename "python-${program_version}-embed-win32.zip")
        set(download_sha512 71c1ce33aa484935306b1a24c75b26193463bb475aa6e1c0f94767649caa22a862c49b2eb341d21f3d8428ae0e4243d5cae1488a83f9f598e23678ee8c548ad8)
    endif()

    set(paths_to_search "${DOWNLOADS}/tools/python/${tool_subdirectory}")

    vcpkg_list(SET post_install_command
        "${CMAKE_COMMAND}" "-DPYTHON_DIR=${paths_to_search}" "-DPYTHON_VERSION=${program_version}" -P "${CMAKE_CURRENT_LIST_DIR}/z_vcpkg_make_python_less_embedded.cmake"
    )
else()
    set(program_name python3.14)
    set(brew_package_name "python@3.14")
    set(apt_package_name "python3.14")
endif()
