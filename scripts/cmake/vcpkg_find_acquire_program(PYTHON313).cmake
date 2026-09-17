if(CMAKE_HOST_WIN32)
    set(program_name python)
    set(program_version 3.13.13)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(build_arch $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(build_arch $ENV{PROCESSOR_ARCHITECTURE})
    endif()
    if(build_arch MATCHES "^(ARM|arm)64$")
        set(tool_subdirectory "python-${program_version}-arm64")
        # https://www.python.org/ftp/python/3.13.13/python-3.13.13-embed-arm64.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-arm64.zip")
        set(download_filename "python-${program_version}-embed-arm64.zip")
        set(download_sha512 045925e59e2bffd5edeffc9dd9761eb3c95c7a01231b8b473845bd4592a282aaf44b034cc6fdcb6e1748a7ed2968d127c6270394a154d0ffaf03b0c065234111)
    elseif(build_arch MATCHES "(amd|AMD)64")
        set(tool_subdirectory "python-${program_version}-x64")
        # https://www.python.org/ftp/python/3.13.13/python-3.13.13-embed-amd64.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-amd64.zip")
        set(download_filename "python-${program_version}-embed-amd64.zip")
        set(download_sha512 3cbf92268243be18798deb1836650253d98ad260eecebea5c715c1d5b698463027b0e907c73d9b304072808c6cb7bed96f23691e944d969978db92da37e22096)
    else()
        set(tool_subdirectory "python-${program_version}-x86")
        # https://www.python.org/ftp/python/3.13.13/python-3.13.13-embed-win32.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-win32.zip")
        set(download_filename "python-${program_version}-embed-win32.zip")
        set(download_sha512 26854919e3fa6eb190535c0b821fe7eefb6f889e2db57693ff171bcf0fa4687c9a184f83be604e99ff9a885ca704daf22921e0bc1d625a763995e78b3fc86207)
    endif()

    set(paths_to_search "${DOWNLOADS}/tools/python/${tool_subdirectory}")

    vcpkg_list(SET post_install_command
        "${CMAKE_COMMAND}" "-DPYTHON_DIR=${paths_to_search}" "-DPYTHON_VERSION=${program_version}" -P "${CMAKE_CURRENT_LIST_DIR}/z_vcpkg_make_python_less_embedded.cmake"
    )
else()
    set(program_name python3.13)
    set(brew_package_name "python@3.13")
    set(apt_package_name "python3.13")
endif()
