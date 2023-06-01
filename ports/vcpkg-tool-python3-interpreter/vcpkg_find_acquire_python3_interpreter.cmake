include_guard(GLOBAL)
function(vcpkg_find_acquire_python3_interpreter out_var)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unrecognized arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(CMAKE_HOST_WIN32)
        set(program_version 3.10.7)
        cmake_host_system_information(RESULT is64_bit QUERY IS_64BIT)
        set(installed_pythons "")
        foreach(candidate IN ITEMS "$ENV{ProgramFiles}/Python3*" "$ENV{ProgramW6432}/Python3*" "$ENV{ProgramFiles\(x86\)}/Python3*")
            file(GLOB more_maybe_pythons LIST_DIRECTORIES TRUE "${candidate}")
            vcpkg_list(APPEND installed_pythons ${more_maybe_pythons})
        endforeach()

        if(is64_bit)
            vcpkg_find_acquire_tool(
                OUT_TOOL_PATH out_var_value
                OUT_TOOL_ACQUIRED tool_acquired
                OUT_EXTRACTED_ROOT out_extract_root
                TOOL_NAME python
                VERSION ${program_version}
                DOWNLOAD_FILENAME "python-${program_version}-embed-win32.zip"
                SHA512 a69445906a909ce5f2554c544fe4251a8ab9c5028b531975b8c78fa8e98295b2bf06e1840f346a3c0edf485a7792c40c9d318bffd36b9c7829ac72b7cf8697bc
                URLS "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-win32.zip"
                TOOL_SUBDIRECTORY "python-${program_version}-x86/python3"
                VERSION_COMMAND "--version"
                VERSION_PREFIX "Python"
                PATHS_TO_SEARCH ${installed_pythons}
            )
        else()
            vcpkg_find_acquire_tool(
                OUT_TOOL_PATH out_var_value
                OUT_TOOL_ACQUIRED tool_acquired
                OUT_EXTRACTED_ROOT out_extract_root
                TOOL_NAME python
                VERSION ${program_version}
                DOWNLOAD_FILENAME "python-${program_version}-embed-amd64.zip"
                SHA512 29b47f8073b54c092a2c8b39b09ab392f757a8c09149e8d2de043907fffb250b5f6801175e16fedb4fae7b6555822acdc57d81d13c2fea95ef0f6ed717f86cb9
                URLS "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-amd64.zip"
                TOOL_SUBDIRECTORY "python-${program_version}-amd64/python3"
                VERSION_COMMAND "--version"
                VERSION_PREFIX "Python"
                PATHS_TO_SEARCH ${installed_pythons}
            )
        endif()

        if(tool_acquired)
            file(REMOVE "${out_extract_root}/python310._pth")
        endif()
    else()
        vcpkg_find_acquire_tool(
            OUT_TOOL_PATH out_var_value
            TOOL_NAME "python3"
            VERSION 3.0.0
            BREW_PACKAGE_NAME "python@3"
            APT_PACKAGE_NAME "python3"
            DNF_PACKAGE_NAME "python"
            ZYPPER_PACKAGE_NAME "python3"
            APK_PACKAGE_NAME "python3"
            VERSION_COMMAND "--version"
            VERSION_PREFIX "Python"
        )
    endif()

    set("${out_var}" "${out_var_value}" PARENT_SCOPE)
endfunction()
