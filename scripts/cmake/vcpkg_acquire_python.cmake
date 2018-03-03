## # vcpkg_acquire_python
##
## Download and prepare Python environment.
##
## ## Usage
## ```cmake
## vcpkg_acquire_msys(<PYTHON_NAME> [PACKAGES <package>...])
## ```
##
## ## Parameters
## ### PYTHON_NAME
## Specify the name with the major version of required python. `${PYTHON_NAME}_EXECUTABLE` will be set to the exectuable path of python if success.
## 
## Any name ending with "2"/"3" will be acceptable. For example, "PYTHON3", "PY2" and "2" are all valid.
##
## ### PACKAGES
## A list of packages to acquire in python.
##
## The python packages will be installed in the same way as doing `pip install <package>`
##
##
## ## Examples
##

function(vcpkg_acquire_python PYTHON_NAME)
    cmake_parse_arguments(_vap "" "" "PACKAGES" ${ARGN})

    string(REGEX MATCH "[0-9]+$" _PYTHON_VERSION ${PYTHON_NAME})
    if(${_PYTHON_VERSION} STREQUAL "2")
        set(TOOLPATH ${DOWNLOADS}/tools/python/python2)
        set(_REQUIRED_PYTHON PYTHON2)
    elseif(${_PYTHON_VERSION} STREQUAL "3")
        set(TOOLPATH ${DOWNLOADS}/tools/python/python3)
        set(_REQUIRED_PYTHON PYTHON3)
    else()
        message(FATAL_ERROR "Specified python name doesn't contain a vaild version number!")
    endif()

    # building the environment
    vcpkg_find_acquire_program(${_REQUIRED_PYTHON})
    if(${_PYTHON_VERSION} STREQUAL "3" AND NOT EXISTS ${TOOLPATH}/python35.zip.extracted)
        # To get around this problem: https://bugs.python.org/issue24960
        file(MAKE_DIRECTORY ${TOOLPATH}/python35)
        vcpkg_extract_source_archive(${TOOLPATH}/python35.zip ${TOOLPATH}/python35)
        vcpkg_execute_required_process(
            COMMAND ${CMAKE_COMMAND} -E tar xjf ${TOOLPATH}/python35.zip
            WORKING_DIRECTORY ${TOOLPATH}/python35
            LOGNAME extract-python-lib
        )
        file(REMOVE ${TOOLPATH}/python35.zip)
        file(RENAME ${TOOLPATH}/python35 ${TOOLPATH}/python35.zip)
        file(WRITE ${TOOLPATH}/python35.zip.extracted)
    endif()

    message(STATUS "Acquiring Python packages...")
    if(_vap_PACKAGES)
        if(NOT EXISTS "${TOOLPATH}/get-pip.py")
            file(DOWNLOAD "https://bootstrap.pypa.io/get-pip.py" ${TOOLPATH}/get-pip.py STATUS download_status)
            list(GET download_status 0 status_code)
                if (NOT "${status_code}" STREQUAL "0")
                    message(FATAL_ERROR "Downloading pip failed. Status: ${download_status}")
                endif()
        endif()

        if(NOT EXISTS "${TOOLPATH}/Lib/site-packages/pip")
            vcpkg_execute_required_process(
                COMMAND ${TOOLPATH}/python.exe ${TOOLPATH}/get-pip.py
                WORKING_DIRECTORY ${TOOLPATH}
                LOGNAME python-install-pip-${TARGET_TRIPLET}
            )
        endif()

        vcpkg_execute_required_process(
            COMMAND ${TOOLPATH}/python.exe -m pip install ${_vap_PACKAGES}
            WORKING_DIRECTORY ${TOOLPATH}
            LOGNAME python-install-packages-${TARGET_TRIPLET}
        )
    endif()
    message(STATUS "Acquiring Python packages... OK")

    set(${PYTHON_NAME}_EXECUTABLE ${TOOLPATH}/python.exe PARENT_SCOPE)
endfunction()
