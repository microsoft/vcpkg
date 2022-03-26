set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

function(vcpkg_get_python_package PYTHON_DIR ) # From mesa
    cmake_parse_arguments(PARSE_ARGV 0 _vgpp "" "PYTHON_EXECUTABLE" "PACKAGES")
    
    if(NOT _vgpp_PYTHON_EXECUTABLE)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} requires parameter PYTHON_EXECUTABLE!")
    endif()
    if(NOT _vgpp_PACKAGES)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} requires parameter PACKAGES!")
    endif()
    if(NOT _vgpp_PYTHON_DIR)
        get_filename_component(_vgpp_PYTHON_DIR "${_vgpp_PYTHON_EXECUTABLE}" DIRECTORY)
    endif()

    if (WIN32)
        set(PYTHON_OPTION "")
    else()
        set(PYTHON_OPTION "--user")
    endif()

    if("${_vgpp_PYTHON_DIR}" MATCHES "${DOWNLOADS}") # inside vcpkg
        if(NOT EXISTS "${_vgpp_PYTHON_DIR}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}")
            if(NOT EXISTS "${_vgpp_PYTHON_DIR}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}")
                vcpkg_from_github(
                    OUT_SOURCE_PATH PYFILE_PATH
                    REPO pypa/get-pip
                    REF 309a56c5fd94bd1134053a541cb4657a4e47e09d #2019-08-25
                    SHA512 bb4b0745998a3205cd0f0963c04fb45f4614ba3b6fcbe97efe8f8614192f244b7ae62705483a5305943d6c8fedeca53b2e9905aed918d2c6106f8a9680184c7a
                    HEAD_REF master
                )
                execute_process(COMMAND "${_vgpp_PYTHON_EXECUTABLE}" "${PYFILE_PATH}/get-pip.py" ${PYTHON_OPTION})
            endif()
            foreach(_package IN LISTS _vgpp_PACKAGES)
                execute_process(COMMAND "${_vgpp_PYTHON_DIR}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}" install ${_package} ${PYTHON_OPTION})
            endforeach()
        else()
            foreach(_package IN LISTS _vgpp_PACKAGES)
                execute_process(COMMAND "${_vgpp_PYTHON_DIR}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}" ${_package})
            endforeach()
        endif()
        if(NOT VCPKG_TARGET_IS_WINDOWS)
            execute_process(COMMAND pip3 install ${_vgpp_PACKAGES})
        endif()
    else() # outside vcpkg
        foreach(_package IN LISTS _vgpp_PACKAGES)
            execute_process(COMMAND ${_vgpp_PYTHON_EXECUTABLE} -c "import ${_package}" RESULT_VARIABLE HAS_ERROR)
            if(HAS_ERROR)
                message(FATAL_ERROR "Python package '${_package}' needs to be installed for port '${PORT}'.\nComplete list of required python packages: ${_vgpp_PACKAGES}")
            endif()
        endforeach()
    endif()
endfunction()

set(${PORT}_PATCHES fix-taglib-search.patch) # Strictly this is only required if qt does not use pkg-config since it forces it to off. 
set(TOOL_NAMES 
        ifmedia-simulation-server
        ifvehiclefunctions-simulation-server
    )

qt_download_submodule(PATCHES ${${PORT}_PATCHES})
if(QT_UPDATE_VERSION)
    return()
endif()

if(_qis_DISABLE_NINJA)
    set(_opt DISABLE_NINJA)
endif()

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${PYTHON3_DIR}")
vcpkg_add_to_path(PREPEND "${PYTHON3_DIR}/Scripts")
vcpkg_get_python_package(PYTHON_EXECUTABLE "${PYTHON3}" PACKAGES virtualenv qface)

if(VCPKG_CROSSCOMPILING)
    list(APPEND FEATURE_OPTIONS "-DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}")
endif()

set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)
qt_cmake_configure(${_opt} 
                   OPTIONS ${FEATURE_OPTIONS}
                        "-DPython3_EXECUTABLE=${PYTHON3}" # Otherwise a VS installation might be found. 
                   OPTIONS_DEBUG ${_qis_CONFIGURE_OPTIONS_DEBUG}
                   OPTIONS_RELEASE ${_qis_CONFIGURE_OPTIONS_RELEASE})

vcpkg_cmake_install(ADD_BIN_TO_PATH)

qt_fixup_and_cleanup(TOOL_NAMES ${TOOL_NAMES})

qt_install_copyright("${SOURCE_PATH}")

if(NOT VCPKG_CROSSCOMPILING)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/ifcodegen")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/ifcodegen" "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/ifcodegen")
endif()
