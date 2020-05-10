include(FindPackageHandleStandardArgs)
function(vcpkg_build_python)
    cmake_parse_arguments(_ppi "" "SOURCE_PATH" "" ${ARGN})
    
    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON_PREFIX ${PYTHON3} DIRECTORY)
    vcpkg_add_to_path(PREPEND ${PYTHON_PREFIX})

      set(PYTHONPATH "${PYTHON_PREFIX}/DLLs;${PYTHON_PREFIX}/Lib;${PYTHON_PREFIX}/Lib/site-packages")#;${PYTHON_PREFIX}/Lib/lib-tk
      set(PYTHONSCRIPT "${PYTHON_PREFIX}/Scripts")
      set(PYTHON_PACKAGES_PATH "${PYTHON_PREFIX}/Lib/site-packages")
	  set(PYTHONHOME "${PYTHON_PREFIX}")
      set(PYTHON_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include/python3.7")
      set(PYTHON_LIBRARY "${CURRENT_INSTALLED_DIR}/lib/python37.lib;${CURRENT_INSTALLED_DIR}/lib")#;${PYTHON_PREFIX}/libs

    if(NOT DEFINED _ppi_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH is a required argument to vcpkg_install_python.")
    endif()
    
    if(DEFINED PYTHON_SEP_DIRS)
        set(PYTHON_SEP_DIRS "\;" ${PYTHON_SEP_DIRS})
    endif()

    message(STATUS "Installing python module for Release..")
    configure_file(${SCRIPTS}/templates/distutils-rel.cfg.in ${PYTHON_PREFIX}/Lib/distutils/distutils.cfg)
    file(REMOVE ${CURRENT_BUILDTREES_DIR}/pip-install-${TARGET_TRIPLET}-rel-detailed.log)
    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} -m pip install .
            --prefix ${PYTHON_PREFIX}
            --ignore-installed --compile --no-deps
            --log ${CURRENT_BUILDTREES_DIR}/pip-install-${TARGET_TRIPLET}-rel-detailed.log
        WORKING_DIRECTORY ${_ppi_SOURCE_PATH}
        LOGNAME pip-install-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Installing python module for Release.. OK")

    file(REMOVE ${PYTHON_PREFIX}/Lib/distutils/distutils.cfg)

    set(VCPKG_POLICY_EMPTY_PACKAGE enabled PARENT_SCOPE)
endfunction()
