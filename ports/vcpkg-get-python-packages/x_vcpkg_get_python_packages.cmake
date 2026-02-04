include_guard(GLOBAL)

function(x_vcpkg_get_python_packages)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "PYTHON_VERSION;PYTHON_EXECUTABLE;REQUIREMENTS_FILE;OUT_PYTHON_VAR" "PACKAGES")

    if(DEFINED arg_PYTHON_VERSION AND NOT DEFINED arg_PYTHON_EXECUTABLE)
        vcpkg_find_acquire_program(PYTHON${arg_PYTHON_VERSION})
        set(arg_PYTHON_EXECUTABLE "${PYTHON${arg_PYTHON_VERSION}}")
    endif()

    if(NOT DEFINED arg_PYTHON_EXECUTABLE AND NOT DEFINED arg_PYTHON_VERSION)
        message(FATAL_ERROR "PYTHON_EXECUTABLE or PYTHON_VERSION must be specified.")
    elseif(NOT DEFINED arg_PYTHON_VERSION)
        if(arg_PYTHON_EXECUTABLE MATCHES "(python3|python-3)")
            set(arg_PYTHON_VERSION 3)
        else()
            set(arg_PYTHON_VERSION 2)
        endif()
    endif()

    if(NOT DEFINED arg_OUT_PYTHON_VAR)
        set(arg_OUT_PYTHON_VAR "PYTHON${arg_PYTHON_VERSION}")
    endif()

    if(NOT DEFINED arg_PACKAGES AND NOT DEFINED arg_REQUIREMENTS_FILE)
        message(FATAL_ERROR "PACKAGES or REQUIREMENTS_FILE must be specified.")
    endif()
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    get_filename_component(python_dir "${arg_PYTHON_EXECUTABLE}" DIRECTORY)
    set(ENV{PYTHONNOUSERSITE} "1")
    if(CMAKE_HOST_WIN32 AND
        ("${python_dir}" MATCHES "(${DOWNLOADS}|${CURRENT_HOST_INSTALLED_DIR})"
        OR (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND ("${python_dir}" MATCHES "(${CURRENT_INSTALLED_DIR})"))
        )) # inside vcpkg and windows host or compatible target.
        if(NOT EXISTS "${python_dir}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}")
            if(NOT EXISTS "${python_dir}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}")
                if(arg_PYTHON_VERSION STREQUAL 3)
                    vcpkg_from_github(
                        OUT_SOURCE_PATH PYFILE_PATH
                        REPO pypa/get-pip
                        REF 24.2
                        SHA512 7bcbc841564b7fc3cd2c109b9d3cfd34d853508edc9e040e9615fc0f9f18f74c7826d53671f65fa1abda3fd29a0a3f9f6114d9e9bdd6d120175ac207fd7ce321
                    )
                    vcpkg_execute_required_process(COMMAND "${arg_PYTHON_EXECUTABLE}" "${PYFILE_PATH}/public/get-pip.py" --no-warn-script-location
                                                   WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                                                   LOGNAME "get-pip-${TARGET_TRIPLET}")
                elseif(arg_PYTHON_VERSION STREQUAL 2)
                    vcpkg_download_distfile(PYFILE
                        URLS "https://bootstrap.pypa.io/pip/2.7/get-pip.py"
                        FILENAME "get-pip.py"
                        SHA512 8c74bdaff57a2dcf2aa69c4c218b7d5f3bf4a470dbda2d7c8d1b53862c84e2a83cd04c3cd20cf80dc0e4076b113a734413e31d6a9853f41e894398e7f88f848e
                    )
                    vcpkg_execute_required_process(COMMAND "${arg_PYTHON_EXECUTABLE}" "${PYFILE}" --no-warn-script-location
                                                   WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                                                   LOGNAME "get-pip-${TARGET_TRIPLET}")
                endif()
            endif()
            vcpkg_execute_required_process(COMMAND "${python_dir}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}" install virtualenv --no-warn-script-location
                                           WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                                           LOGNAME "pip-install-virtualenv-${TARGET_TRIPLET}")
        else()
            vcpkg_execute_required_process(COMMAND "${python_dir}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}" virtualenv --no-warn-script-location #${_package}
                                           WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                                           LOGNAME "easy-install-virtualenv-${TARGET_TRIPLET}")
        endif()
    endif()
    set(venv_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv")
    file(REMOVE_RECURSE "${venv_path}") # Remove old venv
    file(MAKE_DIRECTORY "${venv_path}")
    if(CMAKE_HOST_WIN32)
        file(MAKE_DIRECTORY "${python_dir}/DLLs")
        set(python_sub_path /Scripts)
        set(python_venv virtualenv)
        file(GLOB python_zipped_stdlib "${python_dir}/python3*.zip")
        if(python_zipped_stdlib)
            file(COPY ${python_zipped_stdlib} DESTINATION "${venv_path}/Scripts")
        endif()
        set(python_venv_options "--app-data" "${venv_path}/data")
    else()
        set(python_sub_path /bin)
        if(arg_PYTHON_VERSION STREQUAL 3)
            set(python_venv venv)
        elseif(arg_PYTHON_VERSION STREQUAL 2)
            set(python_venv virtualenv)
        endif()
        set(python_venv_options --symlinks)
    endif()

    set(ENV{PYTHONNOUSERSITE} "1")
    message(STATUS "Setting up python virtual environment...")
    vcpkg_execute_required_process(COMMAND "${arg_PYTHON_EXECUTABLE}" -I -m "${python_venv}" ${python_venv_options} "${venv_path}"
                                   WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                                   LOGNAME "venv-setup-${TARGET_TRIPLET}")
    vcpkg_add_to_path(PREPEND "${venv_path}${python_sub_path}")
    set(${arg_OUT_PYTHON_VAR} "${venv_path}${python_sub_path}/python${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    set(ENV{VIRTUAL_ENV} "${venv_path}")
    unset(ENV{PYTHONHOME})
    unset(ENV{PYTHONPATH})
    if(DEFINED arg_REQUIREMENTS_FILE)
        message(STATUS "Installing requirements from: ${arg_REQUIREMENTS_FILE}")
        vcpkg_execute_required_process(COMMAND "${${arg_OUT_PYTHON_VAR}}" -I -m pip install -r ${arg_REQUIREMENTS_FILE}
                                       WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                                       LOGNAME "pip-install-requirements-file-${TARGET_TRIPLET}")
    endif()
    if(DEFINED arg_PACKAGES)
        message(STATUS "Installing python packages: ${arg_PACKAGES}")
        vcpkg_execute_required_process(COMMAND "${${arg_OUT_PYTHON_VAR}}" -I -m pip install ${arg_PACKAGES}
                                       WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                                       LOGNAME "pip-install-packages-${TARGET_TRIPLET}")
    endif()
    message(STATUS "Setting up python virtual environment... finished.")
    set(${arg_OUT_PYTHON_VAR} "${${arg_OUT_PYTHON_VAR}}" PARENT_SCOPE)
    set(${arg_OUT_PYTHON_VAR} "${${arg_OUT_PYTHON_VAR}}" CACHE PATH "" FORCE)
endfunction()
