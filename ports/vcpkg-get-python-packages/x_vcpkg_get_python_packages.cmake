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
        if(NOT EXISTS "${python_dir}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}")
            if(NOT EXISTS "${python_dir}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}")
                vcpkg_from_github(
                    OUT_SOURCE_PATH PYFILE_PATH
                    REPO pypa/get-pip
                    REF 309a56c5fd94bd1134053a541cb4657a4e47e09d #2019-08-25
                    SHA512 bb4b0745998a3205cd0f0963c04fb45f4614ba3b6fcbe97efe8f8614192f244b7ae62705483a5305943d6c8fedeca53b2e9905aed918d2c6106f8a9680184c7a
                )
                vcpkg_execute_required_process(COMMAND "${arg_PYTHON_EXECUTABLE}" "${PYFILE_PATH}/get-pip.py"
                                               WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}")
            endif()
            foreach(_package IN LISTS arg_PACKAGES)
                vcpkg_execute_required_process(COMMAND "${python_dir}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}" install ${_package}
                                               WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}")
            endforeach()
        else()
            foreach(_package IN LISTS arg_PACKAGES)
                vcpkg_execute_required_process(COMMAND "${python_dir}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}" ${_package}
                                               WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}")
            endforeach()
        endif()
    else() # outside vcpkg
        foreach(package IN LISTS arg_PACKAGES)
            vcpkg_execute_in_download_mode(COMMAND ${arg_PYTHON_EXECUTABLE} -c "import ${package}" RESULT_VARIABLE HAS_ERROR)
            if(HAS_ERROR)
                message(FATAL_ERROR "Python package '${package}' needs to be installed for port '${PORT}'.\nComplete list of required python packages: ${arg_PACKAGES}")
            endif()
        endforeach()
    endif()
endfunction()
