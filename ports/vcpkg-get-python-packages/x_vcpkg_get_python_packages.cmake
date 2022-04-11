#[===[.md:
# x_vcpkg_get_python_packages

Experimental
Retrieve needed python packages

## Usage
```cmake
x_vcpkg_get_python_packages(
    [PYTHON_VERSION (2|3)]
    PYTHON_EXECUTABLE <path to python binary>
    REQUIREMENTS_FILE <file-path>
    PACKAGES <packages to aqcuire>...
    [OUT_PYTHON_VAR somevar]
)
```
## Parameters

### PYTHON_VERSION
Python version to be used. Either 2 or 3

### PYTHON_EXECUTABLE
Full path to the python executable 

### REQUIREMENTS_FILE
Requirement file with the list of python packages

### PACKAGES
List of python packages to acquire

### OUT_PYTHON_VAR
Variable to store the path to the python binary inside the virtual environment


#]===]
include_guard(GLOBAL)

function(x_vcpkg_get_python_packages)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "PYTHON_VERSION;PYTHON_EXECUTABLE;REQUIREMENTS_FILE;OUT_PYTHON_VAR" "PACKAGES")

    if(DEFINED arg_PYTHON_VERSION AND NOT DEFINED arg_PYTHON_EXECUTABLE)
        vcpkg_find_acquire_program(PYTHON${arg_PYTHON_VERSION})
    endif()

    if(NOT DEFINED arg_PYTHON_EXECUTABLE AND NOT DEFINED arg_PYTHON_VERSION)
        message(FATAL_ERROR "PYTHON_EXECUTABLE or PYTHON_VERSION must be specified.")
    elseif(NOT DEFINED arg_PYTHON_EXECUTABLE)
        set(arg_PYTHON_EXECUTABLE "${PYTHON${arg_PYTHON_VERSION}}")
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
    if("${python_dir}" MATCHES "(${DOWNLOADS}|${CURRENT_HOST_INSTALLED_DIR})" AND CMAKE_HOST_WIN32) # inside vcpkg and windows host. 
        #if(NOT EXISTS "${python_dir}/python310._pth" AND PYTHON_EXECUTABLE MATCHES "python3")
        #    file(COPY "${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-get-python-packages/python310._pth" DESTINATION "${python_dir}")
        #endif()
        if(NOT EXISTS "${python_dir}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}")
            if(NOT EXISTS "${python_dir}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}")
                vcpkg_from_github(
                    OUT_SOURCE_PATH PYFILE_PATH
                    REPO pypa/get-pip
                    REF 38e54e5de07c66e875c11a1ebbdb938854625dd8 #2022-03-07
                    SHA512 431a9f66618a2f251db3a8c3311e7fc3af3ff7364ec1d14a99f1b9c237646b6146cef8b9471d83e1086dba2ed448bccc48d99b2bb375e4235d78e76d9970d3e5
                )
                vcpkg_execute_required_process(COMMAND "${arg_PYTHON_EXECUTABLE}" "${PYFILE_PATH}/public/get-pip.py" --no-warn-script-location
                                               WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                                               LOGNAME "get-pip-${TARGET_TRIPLET}")
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
        file(COPY "${python_dir}/python310.zip" DESTINATION "${venv_path}/Scripts")
        set(python_venv_options "--app-data" "${venv_path}/data")
    else()
        set(python_sub_path /bin)
        set(python_venv venv)
        set(python_venv_options --symlinks)
    endif()

    set(ENV{PYTHONNOUSERSITE} "1")
    message(STATUS "Setting up python virtual environmnent...")
    vcpkg_execute_required_process(COMMAND "${PYTHON_EXECUTABLE}" -m "${python_venv}" "${venv_path}" ${python_venv_options}
                                   WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}" 
                                   LOGNAME "venv-setup-${TARGET_TRIPLET}")
    vcpkg_add_to_path(PREPEND "${venv_path}${python_sub_path}")
    set(${arg_OUT_PYTHON_VAR} "${venv_path}${python_sub_path}/python${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    set(ENV{VIRTUAL_ENV} "${venv_path}")
    unset(ENV{PYTHONHOME})
    unset(ENV{PYTHONPATH})
    if(DEFINED arg_REQUIREMENTS_FILE)
        message(STATUS "Installing requirements from: ${arg_REQUIREMENTS_FILE}")
        vcpkg_execute_required_process(COMMAND "${${arg_OUT_PYTHON_VAR}}" -m pip install -r ${arg_REQUIREMENTS_FILE} 
                                       WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}" 
                                       LOGNAME "pip-install-requirements-file-${TARGET_TRIPLET}")
    endif()
    if(DEFINED arg_PACKAGES)
        message(STATUS "Installing python packages: ${arg_PACKAGES}")
        vcpkg_execute_required_process(COMMAND "${${arg_OUT_PYTHON_VAR}}" -m pip install ${arg_PACKAGES} 
                                       WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}" 
                                       LOGNAME "pip-install-packages-${TARGET_TRIPLET}")
    endif()
    message(STATUS "Setting up python virtual environmnent...finished.")
    set(${arg_OUT_PYTHON_VAR} "${PYTHON${arg_PYTHON_VERSION}}" PARENT_SCOPE)
    set(${arg_OUT_PYTHON_VAR} "${PYTHON${arg_PYTHON_VERSION}}" CACHE PATH "" FORCE)
endfunction()
