#[===[.md:
# x_vcpkg_get_python_packages

Experimental
Retrieve needed python packages

## Usage
```cmake
x_vcpkg_get_python_packages(
    <PYTHON_DIR>
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

function(x_vcpkg_get_python_packages PYTHON_DIR )
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "PYTHON_EXECUTABLE" "PACKAGES")
    
    if(NOT arg_PYTHON_EXECUTABLE)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} requires parameter PYTHON_EXECUTABLE!")
    endif()
    if(NOT arg_PACKAGES)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} requires parameter PACKAGES!")
    endif()
    if(NOT arg_PYTHON_DIR)
        get_filename_component(arg_PYTHON_DIR "${arg_PYTHON_EXECUTABLE}" DIRECTORY)
    endif()

    if (WIN32)
        set(PYTHON_OPTION "")
    else()
        set(PYTHON_OPTION "--user")
    endif()

    if("${arg_PYTHON_DIR}" MATCHES "${DOWNLOADS}") # inside vcpkg
        if(NOT EXISTS "${arg_PYTHON_DIR}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}")
            if(NOT EXISTS "${arg_PYTHON_DIR}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}")
                vcpkg_from_github(
                    OUT_SOURCE_PATH PYFILE_PATH
                    REPO pypa/get-pip
                    REF 309a56c5fd94bd1134053a541cb4657a4e47e09d #2019-08-25
                    SHA512 bb4b0745998a3205cd0f0963c04fb45f4614ba3b6fcbe97efe8f8614192f244b7ae62705483a5305943d6c8fedeca53b2e9905aed918d2c6106f8a9680184c7a
                )
                vcpkg_execute_required_process(COMMAND "${arg_PYTHON_EXECUTABLE}" "${PYFILE_PATH}/get-pip.py" ${PYTHON_OPTION}
                                               WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}")
            endif()
            foreach(_package IN LISTS arg_PACKAGES)
                vcpkg_execute_required_process(COMMAND "${arg_PYTHON_DIR}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}" install ${_package} ${PYTHON_OPTION}
                                               WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}")
            endforeach()
        else()
            foreach(_package IN LISTS arg_PACKAGES)
                vcpkg_execute_required_process(COMMAND "${arg_PYTHON_DIR}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}" ${_package}
                                               WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}")
            endforeach()
        endif()
        if(NOT VCPKG_TARGET_IS_WINDOWS)
            vcpkg_execute_required_process(COMMAND pip3 install ${arg_PACKAGES})
        endif()
    else() # outside vcpkg
        foreach(_package IN LISTS arg_PACKAGES)
            vcpkg_execute_in_download_mode(COMMAND ${arg_PYTHON_EXECUTABLE} -c "import ${_package}" RESULT_VARIABLE HAS_ERROR)
            if(HAS_ERROR)
                message(FATAL_ERROR "Python package '${_package}' needs to be installed for port '${PORT}'.\nComplete list of required python packages: ${arg_PACKAGES}")
            endif()
        endforeach()
    endif()
endfunction()