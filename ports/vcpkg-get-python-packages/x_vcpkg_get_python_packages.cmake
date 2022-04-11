#[===[.md:
# x_vcpkg_get_python_packages

Experimental
Retrieve needed python packages

## Usage
```cmake
x_vcpkg_get_python_packages(
    PYTHON_EXECUTABLE <path to python binary>
    PACKAGES <packages to aqcuire>...
)
```
## Parameters

### PYTHON_EXECUTABLE
Full path to the python executable 

### PACKAGES
List of python packages to acquire

#]===]
include_guard(GLOBAL)

function(x_vcpkg_get_python_packages)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "PYTHON_EXECUTABLE;REQUIREMENTS_FILE" "PACKAGES")

    if(NOT DEFINED arg_PYTHON_EXECUTABLE)
        message(FATAL_ERROR "PYTHON_EXECUTABLE must be specified.")
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
        if(NOT EXISTS "${python_dir}/python310._pth" AND PYTHON_EXECUTABLE MATCHES "python3")
            file(COPY "${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-get-python-packages/python310._pth" DESTINATION "${python_dir}")
        endif()
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
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv")
    if(CMAKE_HOST_WIN32)
        file(MAKE_DIRECTORY "${python_dir}/DLLs") 
        set(python_sub_path /Scripts)
        set(python_venv virtualenv)
        file(COPY "${python_dir}/python310.zip" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv/Scripts")
        set(python_venv_options "--app-data" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv/data")
    else()
        set(python_sub_path /bin)
        set(python_venv venv)
        set(python_venv_options --symlinks)
    endif()
    #set(ENV{PYTHON_BIN_PATH} "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv${python_sub_path}")+
    set(ENV{PYTHONNOUSERSITE} "1")
    vcpkg_execute_required_process(COMMAND "${PYTHON3}" -m "${python_venv}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv" ${python_venv_options}
                                   WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}" 
                                   LOGNAME "venv-setup-${TARGET_TRIPLET}")
    vcpkg_add_to_path(PREPEND "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv${python_sub_path}")
    set(PYTHON3 "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv${python_sub_path}/python${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    set(ENV{VIRTUAL_ENV} "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv")
    unset(ENV{PYTHONHOME})
    unset(ENV{PYTHONPATH})
    if(DEFINED arg_REQUIREMENTS_FILE)
        vcpkg_execute_required_process(COMMAND "${PYTHON3}" -m pip install -r ${arg_REQUIREMENTS_FILE} 
                                       WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}" 
                                       LOGNAME "pip-install-requirements-file-${TARGET_TRIPLET}")
    endif()
    if(DEFINED arg_PACKAGES)
        vcpkg_execute_required_process(COMMAND "${PYTHON3}" -m pip install ${arg_PACKAGES} 
                                       WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}" 
                                       LOGNAME "pip-install-packages-${TARGET_TRIPLET}")
    endif()

    set(PYTHON3 "${PYTHON3}" PARENT_SCOPE)
    set(PYTHON3 "${PYTHON3}" CACHE PATH "" FORCE)
endfunction()
