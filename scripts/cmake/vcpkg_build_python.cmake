function(vcpkg_build_python)
    cmake_parse_arguments(_ppi "" "SOURCE_PATH" "" ${ARGN})

    vcpkg_find_acquire_program(PYTHON3)
#    set(Python3_EXECUTABLE ${PYTHON3})
#    set(PYTHON_EXECUTABLE ${Python3_EXECUTABLE})
#    set(PYTHON_PREFIX "${PYTHONHOME}")
#    set(Python3_ROOT_DIR "${PYTHONHOME}")
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

    if(NOT DEFINED _ppi_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH is a required argument to vcpkg_install_python.")
    endif()
    
    if(DEFINED PYTHON_SEP_DIRS)
        set(PYTHON_SEP_DIRS "\;" ${PYTHON_SEP_DIRS})
    endif()

    message(STATUS "Installing python module for Release..")
    configure_file(${SCRIPTS}/templates/distutils-rel.cfg.in
        ${PYTHONHOME}/Lib/distutils/distutils.cfg)
    file(REMOVE ${CURRENT_BUILDTREES_DIR}/pip-install-${TARGET_TRIPLET}-rel-detailed.log)
    vcpkg_execute_required_process(
        COMMAND ${Python3_EXECUTABLE} -m pip install .
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
