include_guard(GLOBAL)

function(z_vcpkg_get_gobject_introspection_python out_var)
    if(VCPKG_CROSSCOMPILING)
        message(STATUS
            "Cross build. " 
            "Using ${TARGET_TRIPLET} python also for the host (${HOST_TRIPLET}). "
            "Building and using ${PORT} will fail if the host cannot execute target binaries."
        )
    endif()
    if(EXISTS "${CURRENT_HOST_INSTALLED_DIR}/share/python3/vcpkg-port-config.cmake")
        # Engage host python include guards. (Host python is not a dependency.)
        include("${CURRENT_HOST_INSTALLED_DIR}/share/python3/vcpkg-port-config.cmake")
    endif()
    # Load target python config in global scope.
    include("${CURRENT_INSTALLED_DIR}/share/python3/vcpkg-port-config.cmake")
    block(SCOPE_FOR VARIABLES PROPAGATE gobject_introspection_python)
        if(VCPKG_CROSSCOMPILING)
            # Pretend native build in order to use vcpkg installed python for TARGET_TRIPLET.
            set(VCPKG_CROSSCOMPILING 0)
            set(HOST_TRIPLET "${TARGET_TRIPLET}")
            set(CURRENT_HOST_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}")
            set(VCPKG_HOST_EXECUTABLE_SUFFIX "${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
            unset(z_vcpkg_get_vcpkg_installed_python CACHE)
        endif()
        vcpkg_get_vcpkg_installed_python(target_python)

        # Varation of x_vcpkg_get_python_packages, using venv also for windows
        message(STATUS "Setting up python virtual environment...")
        set(venv_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv")
        file(REMOVE_RECURSE "${venv_path}") # Remove old venv
        file(MAKE_DIRECTORY "${venv_path}")

        set(python_sub_path /bin)
        set(python_venv_options --symlinks)
        if(CMAKE_HOST_WIN32)
            set(python_sub_path /Scripts)
            set(python_venv_options --copies)

            get_filename_component(python_dir "${target_python}" DIRECTORY)
            file(MAKE_DIRECTORY "${python_dir}/DLLs")
            file(GLOB python_zipped_stdlib "${python_dir}/python3*.zip")
            if(python_zipped_stdlib)
                file(COPY ${python_zipped_stdlib} DESTINATION "${venv_path}/Scripts")
            endif()
        endif()

        set(ENV{PYTHONNOUSERSITE} "1")
        vcpkg_execute_required_process(
            COMMAND "${target_python}" -I -m venv ${python_venv_options} "${venv_path}"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            LOGNAME "venv-setup-${TARGET_TRIPLET}"
        )
        set(gobject_introspection_python "${venv_path}${python_sub_path}/python${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        set(ENV{VIRTUAL_ENV} "${venv_path}")
        unset(ENV{PYTHONHOME})
        unset(ENV{PYTHONPATH})
        message(STATUS "Installing python packages: setuptools")
        vcpkg_execute_required_process(
            COMMAND "${gobject_introspection_python}" -I -m pip install setuptools
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            LOGNAME "pip-install-packages-${TARGET_TRIPLET}"
        )
        message(STATUS "Setting up python virtual environment... finished.")
    endblock()
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
