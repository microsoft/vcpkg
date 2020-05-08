#include(FindPackageHandleStandardArgs)
function(vcpkg_build_python)
    cmake_parse_arguments(_ppi "" "SOURCE_PATH" "" ${ARGN})

    vcpkg_find_acquire_program(PYTHON3)
      find_program(Python3_EXECUTABLE NAMES python python3 python3.7 NAMES_PER_DIR HINTS ${PYTHON3} NO_DEFAULT_PATH)
      get_filename_component(PYTHON3_DIR ${PYTHON3} PATH)
        vcpkg_add_to_path(PREPEND ${PYTHON3_DIR})
        set(PYTHONHOME "${PYTHON3_DIR}")
#        set(PYTHON_ARCH "64")
        set(PYTHON "${PYTHON3_DIR}")
#        set(PYVER "3.7")
#        set(Python3_VERSION "3.7")
        set(PYTHON_PREFIX "${PYTHONHOME}")
        set(CONDA_PREFIX "${PYTHONHOME}")
        set(CONDA_ROOT "${PYTHONHOME}")
        set(ANACONDA_PYTHON_DIR "${PYTHONHOME}")
        set(CONDA_PYTHON_EXE "${Python3_EXECUTABLE}")
#        set(ENV{Python3_ROOT_DIR} "$ENV{PYTHONHOME}")
#        set(Python3_ROOT_DIR "${CONDA_ROOT}/envs/py36_64/")
#        set(Python3_ROOT_DIR "${CONDA_ROOT}")
        set(Python3_ROOT_DIR "${PYTHONHOME}")
        set(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")
        set(PYTHON_DEFAULT_EXECUTABLE "${Python3_EXECUTABLE}")
#        set(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")
#        set(PYTHON3_EXECUTABLE "${Python3_EXECUTABLE}")
#        set(Python3 "${PYTHON_EXECUTABLE}")
        set(PYTHONPATH "${PYTHONHOME}/Lib;${PYTHONHOME}/DLLs;${PYTHONHOME}/Lib/site-packages")#;${PYTHONHOME}/Lib/lib-tk
        set(PYTHONSCRIPT "${PYTHONHOME}/Scripts")
        set(PYTHON_PACKAGES_PATH "${PYTHONHOME}/Lib/site-packages")
        set(PYTHON3_PACKAGES_PATH "${PYTHON_PACKAGES_PATH}")
        set(PYTHON3_INCLUDE_DIRS "${PYTHON_INCLUDE_DIR}")
        set(PYTHON_INCLUDE_DIRS "${PYTHON_INCLUDE_DIR}")
        set(PYTHON_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include/python3.7")
        set(PYTHON3_LIBRARY "${PYTHON_LIBRARY}")
        set(PYTHON_LIBRARIES "${PYTHON_LIBRARY}")
        set(PYTHON_LIBRARY "${CURRENT_INSTALLED_DIR}/lib/python37.lib;${CURRENT_INSTALLED_DIR}/lib")#;${PYTHONHOME}/libs
        vcpkg_add_to_path(PREPEND ${PYTHONSCRIPT})
#        find_package_handle_standard_args(Python3 DEFAULT_MSG Python3_EXECUTABLE)
#        find_package_handle_standard_args(Python3Interp DEFAULT_MSG Python3_EXECUTABLE)
#        if(Python3_EXECUTABLE)
#          execute_process(COMMAND ${Python3_EXECUTABLE} --version
#          OUTPUT_VARIABLE PYTHON_VERSION_STRING ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
#        endif()
#      find_package_handle_standard_args(Python3Interp REQUIRED_VARS Python3_EXECUTABLE VERSION_VAR PYTHON_VERSION_STRING)
#      find_package_handle_standard_args(Python3 REQUIRED_VARS Python3_EXECUTABLE VERSION_VAR PYTHON_VERSION_STRING)
      mark_as_advanced(Python3_EXECUTABLE)

###    set(PYTHON_EXECUTABLE ${Python3_EXECUTABLE})
#    set(PYTHON_DEBUG_EXECUTABLE ${CURRENT_INSTALLED_DIR}/debug/python3/python_d.exe)

    if(NOT DEFINED _ppi_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH is a required argument to vcpkg_install_python.")
    endif()
    
    
    if(DEFINED PYTHON_SEP_DIRS)
        set(PYTHON_SEP_DIRS "\;" ${PYTHON_SEP_DIRS})
    endif()
    
    # prepend semicolon
#    if(DEFINED VCPKG_PYTHON_INCLUDE_DIRS)
#        set(VCPKG_PYTHON_INCLUDE_DIRS "\;" ${VCPKG_PYTHON_INCLUDE_DIRS})
#    endif()
#    if(DEFINED VCPKG_PYTHON_DEBUG_LIBS)
#        set(VCPKG_PYTHON_DEBUG_LIBS "\;" ${VCPKG_PYTHON_DEBUG_LIBS})
#    endif()
#    if(DEFINED VCPKG_PYTHON_LIBS)
#        set(VCPKG_PYTHON_LIBS "\;" ${VCPKG_PYTHON_LIBS})
#    endif()

#    message(STATUS "Installing python module for Debug..")
#    configure_file(${CURRENT_INSTALLED_DIR}/share/python3-setuptools/distutils-dbg.cfg.in
#        ${CURRENT_INSTALLED_DIR}/debug/python3/Lib/distutils/distutils.cfg)
#    file(REMOVE ${CURRENT_BUILDTREES_DIR}/pip-install-${TARGET_TRIPLET}-dbg-detailed.log)
#    vcpkg_execute_required_process(
#        COMMAND ${PYTHON_DEBUG_EXECUTABLE} -m pip install .
#            --prefix ${CURRENT_PACKAGES_DIR}/debug/python
#            --ignore-installed --compile --no-deps
#            compiler=msvc | compiler=bcpp | compiler=cygwin | compiler=mingw32
###            regulated in the file, #system 	prefix\Lib\distutils\distutils.cfg, #personal 	%HOME%\pydistutils.cfg, #local 	setup.cfg
#            --log ${CURRENT_BUILDTREES_DIR}/pip-install-${TARGET_TRIPLET}-dbg-detailed.log
#        WORKING_DIRECTORY ${_ppi_SOURCE_PATH}
#        LOGNAME pip-install-${TARGET_TRIPLET}-dbg
#    )
#    file(REMOVE ${CURRENT_INSTALLED_DIR}/debug/python3/Lib/distutils/distutils.cfg)
#    message(STATUS "Installing python module for Debug.. OK")

    message(STATUS "Installing python module for Release..")
    configure_file(${SCRIPTS}/templates/distutils-rel.cfg.in
        ${PYTHONHOME}/Lib/distutils/distutils.cfg)
    file(REMOVE ${CURRENT_BUILDTREES_DIR}/pip-install-${TARGET_TRIPLET}-rel-detailed.log)
    vcpkg_execute_required_process(
        COMMAND ${PYTHON_EXECUTABLE} -m pip install .
            --prefix ${PYTHONHOME}
            --ignore-installed --compile --no-deps
#            compiler=msvc | compiler=bcpp | compiler=cygwin | compiler=mingw32
###            regulated in the file, #system 	prefix\Lib\distutils\distutils.cfg, #personal 	%HOME%\pydistutils.cfg, #local 	setup.cfg
            --log ${CURRENT_BUILDTREES_DIR}/pip-install-${TARGET_TRIPLET}-rel-detailed.log
        WORKING_DIRECTORY ${_ppi_SOURCE_PATH}
        LOGNAME pip-install-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Installing python module for Release.. OK")

    file(REMOVE ${PYTHONHOME}/Lib/distutils/distutils.cfg)

    set(VCPKG_POLICY_EMPTY_PACKAGE enabled PARENT_SCOPE)
endfunction()
