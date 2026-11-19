if(CMAKE_HOST_WIN32)
    set(program_name python)
    set(program_version 3.15.2)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(build_arch $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(build_arch $ENV{PROCESSOR_ARCHITECTURE})
    endif()
    if(build_arch MATCHES "^(ARM|arm)64$")
        set(tool_subdirectory "python-${program_version}-arm64")
        # https://www.python.org/ftp/python/3.15.2/python-3.15.2-embed-arm64.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-arm64.zip")
        set(download_filename "python-${program_version}-embed-arm64.zip")
        set(download_sha512 3765f7c60e82ab7c8b4e5ae164b3a5ae3fc5110bd2a897e2131322bef492cc2a30e4daeb33f92b12b1946afbd919dbd1c09af07b91070442cfcfc50fba09dd8f)
    elseif(build_arch MATCHES "(amd|AMD)64")
        set(tool_subdirectory "python-${program_version}-x64")
        # https://www.python.org/ftp/python/3.15.2/python-3.15.2-embed-amd64.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-amd64.zip")
        set(download_filename "python-${program_version}-embed-amd64.zip")
        set(download_sha512 d03cfd58fe9aedd5bf8612c0a17f25a7ef82557a2ef5fe3703827ac98f69b153236a1acd4c817fcbea4ccece1990cbf0e2cf3eb5880ff39226f1ebaef8fcc02c)
    else()
        set(tool_subdirectory "python-${program_version}-x86")
        # https://www.python.org/ftp/python/3.15.2/python-3.15.2-embed-win32.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-win32.zip")
        set(download_filename "python-${program_version}-embed-win32.zip")
        set(download_sha512 539c9abae4000021a987f11d8e5a6d746e3456536fc29e8b6d1f869da225396cf0b0fe3f384812cafdc4dfc1a4155af06a78938f1942b33d403365f0a003773e)
    endif()

    set(paths_to_search "${DOWNLOADS}/tools/python/${tool_subdirectory}")

    vcpkg_list(SET post_install_command
        "${CMAKE_COMMAND}" "-DPYTHON_DIR=${paths_to_search}" "-DPYTHON_VERSION=${program_version}" -P "${CMAKE_CURRENT_LIST_DIR}/z_vcpkg_make_python_less_embedded.cmake"
    )
else()
    set(program_name python3)
    set(brew_package_name "python")
    set(apt_package_name "python3")
endif()
