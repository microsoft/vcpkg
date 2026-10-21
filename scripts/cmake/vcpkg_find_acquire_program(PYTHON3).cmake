if(CMAKE_HOST_WIN32)
    set(program_name python)
    set(program_version 3.14.7)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(build_arch $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(build_arch $ENV{PROCESSOR_ARCHITECTURE})
    endif()
    if(build_arch MATCHES "^(ARM|arm)64$")
        set(tool_subdirectory "python-${program_version}-arm64")
        # https://www.python.org/ftp/python/3.14.7/python-3.14.7-embed-arm64.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-arm64.zip")
        set(download_filename "python-${program_version}-embed-arm64.zip")
        set(download_sha512 9abaf6d410a597280627e2921bb63128dc59f54159af14011c98c271fcebfe2cec26b23aa6ab207fe64cdac3a268b72864ee95d3dca0d8025c16a19c2346801b)
    elseif(build_arch MATCHES "(amd|AMD)64")
        set(tool_subdirectory "python-${program_version}-x64")
        # https://www.python.org/ftp/python/3.14.7/python-3.14.7-embed-amd64.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-amd64.zip")
        set(download_filename "python-${program_version}-embed-amd64.zip")
        set(download_sha512 c62810365c120d192767c02b471ea38d100d29ae8332fa00318d1ee66fa7f75b14f01962d3a1b47e935994d2b1e4a76f3bc44bc2bc67cbf0618a2214dfb73a02)
    else()
        set(tool_subdirectory "python-${program_version}-x86")
        # https://www.python.org/ftp/python/3.14.7/python-3.14.7-embed-win32.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-win32.zip")
        set(download_filename "python-${program_version}-embed-win32.zip")
        set(download_sha512 1f73cbfff5f1b28a7dc5752143e45342578fb391451c306c7bc9cf12f9909c21da458c24a81346f0c02f6404c4b652c2c3ff51e6ab667f0e69c6a7e29f55fba0)
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
