if(CMAKE_HOST_WIN32)
    set(program_name python)
    set(program_version 3.14.2)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(build_arch $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(build_arch $ENV{PROCESSOR_ARCHITECTURE})
    endif()
    if(build_arch MATCHES "^(ARM|arm)64$")
        set(tool_subdirectory "python-${program_version}-arm64")
        # https://www.python.org/ftp/python/3.14.2/python-3.14.2-embed-arm64.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-arm64.zip")
        set(download_filename "python-${program_version}-embed-arm64.zip")
        set(download_sha512 410C785D1BC8F3D1352E5386E53AB0AEF39E1212680E2E05DAAD5672DCC749CCFAB96E204C84B3C1E9544002088E1412CA733B1A86CA4CC920549C41774F6C58)
    elseif(build_arch MATCHES "(amd|AMD)64")
        set(tool_subdirectory "python-${program_version}-x64")
        # https://www.python.org/ftp/python/3.14.2/python-3.14.2-embed-amd64.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-amd64.zip")
        set(download_filename "python-${program_version}-embed-amd64.zip")
        set(download_sha512 D72D4F036C4DD563C4AC15C7162BF63406D3FD83A44877300FF87E4168F211D66B8209FDD3AD39EA549B8BC46C092B4ECAB3B24B0DA2F8950E0E5642828E99F2)
    else()
        set(tool_subdirectory "python-${program_version}-x86")
        # https://www.python.org/ftp/python/3.14.2/python-3.14.2-embed-win32.zip
        set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-win32.zip")
        set(download_filename "python-${program_version}-embed-win32.zip")
        set(download_sha512 05703133A3371493CCD3552DD12DB6385CBB1A34874056C8A3F26DDA6B813BF2BD535549C30AA4C0827287D9C4FF3250A49330282AD8535A06937B016D483010)
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
