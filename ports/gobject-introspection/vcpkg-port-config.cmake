include_guard(GLOBAL)

function(z_vcpkg_get_gobject_introspection_python out_var)
    if(VCPKG_CROSSCOMPILING)
        message(STATUS
            "Cross build with gobject-introspection. "
            "Building and using ${PORT} will fail if the host cannot execute target binaries."
        )
    endif()

    set(target_python "${CURRENT_INSTALLED_DIR}/tools/python3/python3${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    if(VCPKG_TARGET_IS_WINDOWS)
        set(target_python "${CURRENT_INSTALLED_DIR}/tools/python3/python.exe")
    endif()
    
    # Varation of x_vcpkg_get_python_packages, but
    # - providing the interpreter for the target
    # - using venv also for windows
    message(STATUS "Setting up ${TARGET_TRIPLET} python venv which provides setuptools...")
    set(venv_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-gir-venv")
    file(REMOVE_RECURSE "${venv_path}")
    file(MAKE_DIRECTORY "${venv_path}")

    set(python_sub_path /bin)
    set(python_venv_options --symlinks)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(python_sub_path /Scripts)
        set(python_venv_options --copies)
    endif()

    set(ENV{PYTHONNOUSERSITE} "1")
    vcpkg_execute_required_process(
        COMMAND "${target_python}" -I -m venv ${python_venv_options} "${venv_path}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "venv-init-${TARGET_TRIPLET}"
    )

    set(gobject_introspection_python "${venv_path}${python_sub_path}/python${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    set(ENV{VIRTUAL_ENV} "${venv_path}")
    unset(ENV{PYTHONHOME})
    unset(ENV{PYTHONPATH})
    vcpkg_execute_required_process(
        COMMAND "${gobject_introspection_python}" -I -m pip install setuptools
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "venv-install-setuptools-${TARGET_TRIPLET}"
    )

    message(STATUS "Finished (with ${out_var} at ${gobject_introspection_python})")
    set("${out_var}" "${gobject_introspection_python}" PARENT_SCOPE)
endfunction()

function(vcpkg_get_gobject_introspection_programs)
    if("PYTHON3" IN_LIST ARGN)
        z_vcpkg_get_gobject_introspection_python(PYTHON3)
        set(PYTHON3 "${PYTHON3}" PARENT_SCOPE)
        list(REMOVE_ITEM ARGN "PYTHON3")
    endif()
    if("GIR_COMPILER" IN_LIST ARGN)
        set(GIR_COMPILER "${CURRENT_INSTALLED_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_TARGET_EXECUTABLE_SUFFIX}" PARENT_SCOPE)
        list(REMOVE_ITEM ARGN "GIR_COMPILER")
    endif()
    if("GIR_SCANNER" IN_LIST ARGN)
        set(GIR_SCANNER "${CURRENT_INSTALLED_DIR}/tools/gobject-introspection/g-ir-scanner" PARENT_SCOPE)
        list(REMOVE_ITEM ARGN "GIR_SCANNER")
    endif()
    if(NOT ARGN STREQUAL "")
        message(FATAL_ERROR "Unsupported arguments: ${ARGN}")
    endif()
endfunction()
