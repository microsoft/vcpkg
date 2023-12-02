include_guard(GLOBAL)
function(vcpkg_find_acquire_python3_interpreter out_var)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "MIN_VERSION" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unrecognized arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(CMAKE_HOST_WIN32)
        set(program_version 3.11.5)
        if(DEFINED arg_MIN_VERSION AND ("${program_version}" VERSION_LESS "${arg_MIN_VERSION}"))
            message(FATAL_ERROR "This function fetches Python ${program_version}, but ${arg_MIN_VERSION} was requested.")
        endif()

        cmake_host_system_information(RESULT is64_bit QUERY IS_64BIT)
        set(installed_pythons "")
        foreach(candidate IN ITEMS "$ENV{ProgramFiles}/Python3*" "$ENV{ProgramW6432}/Python3*" "$ENV{ProgramFiles\(x86\)}/Python3*")
            file(GLOB more_maybe_pythons LIST_DIRECTORIES TRUE "${candidate}")
            vcpkg_list(APPEND installed_pythons ${more_maybe_pythons})
        endforeach()

        if(is64_bit)
            vcpkg_find_acquire_tool(
                OUT_TOOL_COMMAND out_tool_command
                OUT_DOWNLOAD_TOOL_DIRECTORY download_directory
                TOOL_NAME python
                VERSION ${program_version}
                DOWNLOAD_FILENAME "python-${program_version}-embed-amd64.zip"
                SHA512 29a526da7624423b09ea1c8f94d83e5ad2d7ba7553c5651d8fcbe1b2483c62f27f9db105d1fdcfca3357b44d456fe1141274725bc97ad5166edfec14f251eb36
                URLS "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-amd64.zip"
                TOOL_SUBDIRECTORY "python-${program_version}-amd64/python3"
                VERSION_COMMAND "--version"
                VERSION_PREFIX "Python"
                SEARCH_PATHS ${installed_pythons}
            )
        else()
            vcpkg_find_acquire_tool(
                OUT_TOOL_COMMAND out_tool_command
                OUT_DOWNLOAD_TOOL_DIRECTORY download_directory
                TOOL_NAME python
                VERSION ${program_version}
                DOWNLOAD_FILENAME "python-${program_version}-embed-win32.zip"
                SHA512 d5412c5bc2a0664f86e504a536c201789c8fd8b97c641bbb7b254c87c2f13504d25fa9d0b74e27a1c54c2d9fb592f9546d8c1e82c506dc9c76a21774c4c3ea75
                URLS "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-win32.zip"
                TOOL_SUBDIRECTORY "python-${program_version}-x86/python3"
                VERSION_COMMAND "--version"
                VERSION_PREFIX "Python"
                SEARCH_PATHS ${installed_pythons}
            )
        endif()

        if(DEFINED download_directory)
            file(REMOVE "${download_directory}/python311._pth")
        endif()
    else()
        set(SEARCH_VERSION "3.0.0")
        if(DEFINED arg_MIN_VERSION)
            set(SEARCH_VERSION "${arg_MIN_VERSION}")
        endif()

        vcpkg_find_acquire_tool(
            OUT_TOOL_COMMAND out_tool_command
            TOOL_NAME "python3"
            VERSION "${SEARCH_VERSION}"
            BREW_PACKAGE_NAME "python@3"
            APT_PACKAGE_NAME "python3"
            DNF_PACKAGE_NAME "python"
            ZYPPER_PACKAGE_NAME "python3"
            APK_PACKAGE_NAME "python3"
            VERSION_COMMAND "--version"
            VERSION_PREFIX "Python"
        )
    endif()

    set("${out_var}" "${out_tool_command}" PARENT_SCOPE)
endfunction()
