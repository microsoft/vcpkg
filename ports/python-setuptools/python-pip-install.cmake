function(python_pip_install)
    cmake_parse_arguments(_ppi "" "SOURCE_PATH" "" ${ARGN})

    set(PYTHON_EXECUTABLE ${CURRENT_INSTALLED_DIR}/python/python.exe)
    set(PYTHON_DEBUG_EXECUTABLE ${CURRENT_INSTALLED_DIR}/debug/python/python_d.exe)

    if(NOT DEFINED _ppi_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH is a required argument to python-pip-install.")
    endif()
    
    # prepend semicolon
    if(DEFINED VCPKG_PYTHON_INCLUDE_DIRS)
        set(VCPKG_PYTHON_INCLUDE_DIRS "\;" ${VCPKG_PYTHON_INCLUDE_DIRS})
    endif()
    if(DEFINED VCPKG_PYTHON_DEBUG_LIBS)
        set(VCPKG_PYTHON_DEBUG_LIBS "\;" ${VCPKG_PYTHON_DEBUG_LIBS})
    endif()
    if(DEFINED VCPKG_PYTHON_LIBS)
        set(VCPKG_PYTHON_LIBS "\;" ${VCPKG_PYTHON_LIBS})
    endif()

    message(STATUS "Installing python module for Debug..")
    configure_file(${CURRENT_INSTALLED_DIR}/share/python-setuptools/distutils-dbg.cfg.in
        ${CURRENT_INSTALLED_DIR}/debug/python/Lib/distutils/distutils.cfg)
    file(REMOVE ${CURRENT_BUILDTREES_DIR}/pip-install-${TARGET_TRIPLET}-dbg-detailed.log)
    vcpkg_execute_required_process(
        COMMAND ${PYTHON_DEBUG_EXECUTABLE} -m pip install .
            --prefix ${CURRENT_PACKAGES_DIR}/debug/python
            --ignore-installed --compile --no-deps
            --log ${CURRENT_BUILDTREES_DIR}/pip-install-${TARGET_TRIPLET}-dbg-detailed.log
        WORKING_DIRECTORY ${_ppi_SOURCE_PATH}
        LOGNAME pip-install-${TARGET_TRIPLET}-dbg
    )
    file(REMOVE ${CURRENT_INSTALLED_DIR}/debug/python/Lib/distutils/distutils.cfg)
    message(STATUS "Installing python module for Debug.. OK")

    message(STATUS "Installing python module for Release..")
    configure_file(${CURRENT_INSTALLED_DIR}/share/python-setuptools/distutils-rel.cfg.in
        ${CURRENT_INSTALLED_DIR}/python/Lib/distutils/distutils.cfg)
    file(REMOVE ${CURRENT_BUILDTREES_DIR}/pip-install-${TARGET_TRIPLET}-rel-detailed.log)
    vcpkg_execute_required_process(
        COMMAND ${PYTHON_EXECUTABLE} -m pip install .
            --prefix ${CURRENT_PACKAGES_DIR}/python
            --ignore-installed --compile --no-deps
            --log ${CURRENT_BUILDTREES_DIR}/pip-install-${TARGET_TRIPLET}-rel-detailed.log
        WORKING_DIRECTORY ${_ppi_SOURCE_PATH}
        LOGNAME pip-install-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Installing python module for Release.. OK")
    file(REMOVE ${CURRENT_INSTALLED_DIR}/python/Lib/distutils/distutils.cfg)
    
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled PARENT_SCOPE)
endfunction()