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
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "PYTHON_EXECUTABLE" "PACKAGES")

    if(NOT DEFINED arg_PYTHON_EXECUTABLE)
        message(FATAL_ERROR "PYTHON_EXECUTABLE must be specified.")
    endif()
    if(NOT DEFINED arg_PACKAGES)
        message(FATAL_ERROR "PACKAGES must be specified.")
    endif()
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    get_filename_component(python_dir "${arg_PYTHON_EXECUTABLE}" DIRECTORY)

    if("${python_dir}" MATCHES "(${DOWNLOADS}|${CURRENT_HOST_INSTALLED_DIR})" AND CMAKE_HOST_WIN32) # inside vcpkg and windows host. 
        file(COPY "${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-get-python-packages/python310._pth" DESTINATION "${python_dir}")
        if(NOT EXISTS "${python_dir}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}")
            if(NOT EXISTS "${python_dir}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}")
                vcpkg_from_github(
                    OUT_SOURCE_PATH PYFILE_PATH
                    REPO pypa/get-pip
                    REF 309a56c5fd94bd1134053a541cb4657a4e47e09d #2019-08-25
                    SHA512 bb4b0745998a3205cd0f0963c04fb45f4614ba3b6fcbe97efe8f8614192f244b7ae62705483a5305943d6c8fedeca53b2e9905aed918d2c6106f8a9680184c7a
                )
                vcpkg_execute_required_process(COMMAND "${arg_PYTHON_EXECUTABLE}" "${PYFILE_PATH}/get-pip.py"
                                               WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                                               LOGNAME "get-pip-${TARGET_TRIPLET}")
            endif()
            vcpkg_execute_required_process(COMMAND "${python_dir}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}" install virtualenv
                                           WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                                           LOGNAME "pip-install-virtualenv-${TARGET_TRIPLET}")
        else()
            vcpkg_execute_required_process(COMMAND "${python_dir}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}" virtualenv #${_package}
                                           WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                                           LOGNAME "easy-install-virtualenv-${TARGET_TRIPLET}")
        endif()
        
    #else() # outside vcpkg
    #    foreach(package IN LISTS arg_PACKAGES)
    #        string(REGEX REPLACE "[>=<]+.+" "" package_no_version "${package}") # Remove version constrins for testing
    #        vcpkg_execute_in_download_mode(COMMAND ${arg_PYTHON_EXECUTABLE} -c "import ${package_no_version}" RESULT_VARIABLE HAS_ERROR)
    #        if(HAS_ERROR)
    #            message(FATAL_ERROR "Python package '${package}' needs to be installed for port '${PORT}'.\nComplete list of required python packages: ${arg_PACKAGES}")
    #        endif()
    #    endforeach()
    endif()
        
    vcpkg_execute_required_process(COMMAND "${PYTHON3}" -m venv --symlinks "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv"
                                   WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}" 
                                   LOGNAME "prerequisites-venv-${TARGET_TRIPLET}")
    vcpkg_add_to_path(PREPEND "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv/bin")
    set(PYTHON3 "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv/bin/python3${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    set(ENV{VIRTUAL_ENV} "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv")
    vcpkg_execute_required_process(COMMAND "${PYTHON3}" -c "import site; print(site.getusersitepackages())" 
                                   WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}" 
                                   LOGNAME "prerequisites-pypath-${TARGET_TRIPLET}" 
                                   OUTPUT_VARIABLE PYTHON_LIB_PATH)
    set(ENV{PYTHON_BIN_PATH} "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv/bin/")
    set(ENV{PYTHON_LIB_PATH} "${PYTHON_LIB_PATH}")
    vcpkg_execute_required_process(COMMAND "${PYTHON3}" -m pip install -U ${arg_PACKAGES} 
                                   WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}" 
                                   LOGNAME "prerequisites-pip-${TARGET_TRIPLET}")
endfunction()
