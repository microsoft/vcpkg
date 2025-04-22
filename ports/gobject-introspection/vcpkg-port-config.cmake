include_guard(GLOBAL)

function(vcpkg_get_gobject_introspection_python out_var)
    if(VCPKG_CROSSCOMPILING)
        message(STATUS
            "Cross build. " 
            "Using ${TARGET_TRIPLET} python also for the host (${HOST_TRIPLET}). "
            "Building and using ${PORT} will fail if the host cannot execute target binaries."
        )
    endif()
    include("${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-get-python-packages/vcpkg-port-config.cmake")
    if(EXISTS "${CURRENT_HOST_INSTALLED_DIR}/share/python3/vcpkg-port-config.cmake")
        # Engage host python include guards.
        include("${CURRENT_HOST_INSTALLED_DIR}/share/python3/vcpkg-port-config.cmake")
    endif()
    # Load target python config.
    include("${CURRENT_INSTALLED_DIR}/share/python3/vcpkg-port-config.cmake")
    block(SCOPE_FOR VARIABLES PROPAGATE gobject_introspection_python)
        # Pretend native build, get vcpkg installed python for TARGET_TRIPLET.
        set(VCPKG_CROSSCOMPILING 0)
        set(HOST_TRIPLET "${TARGET_TRIPLET}")
        set(CURRENT_HOST_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}")
        set(VCPKG_HOST_EXECUTABLE_SUFFIX "${VCPKG_TARGET_EXECUTABLE_SUFFIX}")

        vcpkg_get_vcpkg_installed_python(target_python)
        string(FIND "${target_python}" "${CURRENT_INSTALLED_DIR}/tools" index)
        if(NOT index STREQUAL "0")
            message(FATAL_ERROR "Not the target python: ${target_python}")
        endif()

        x_vcpkg_get_python_packages(OUT_PYTHON_VAR gobject_introspection_python
            PYTHON_EXECUTABLE "${target_python}"
            PYTHON_VERSION "3"
            PACKAGES setuptools
        )
    endblock()
    set("${out_var}" "${gobject_introspection_python}" PARENT_SCOPE)
endfunction()

function(vcpkg_get_gobject_introspection_programs)
    if("PYTHON3" IN_LIST ARGN)
        vcpkg_get_gobject_introspection_python(PYTHON3)
        set(PYTHON3 "${PYTHON3}" PARENT_SCOPE)
        list(REMOVE_ITEM ARGN "PYTHON3")
    endif()
    if("GIR_COMPILER" IN_LIST ARGN)
        set(GIR_COMPILER "${CURRENT_INSTALLED_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_TARGET_EXECUTABLE_SUFFIX}" PARENT_SCOPE)
        list(REMOVE_ITEM ARGN "GIR_COMPILER")
    endif()
    if("GIR_SCANNER" IN_LIST ARGN)
        set(GIR_SCANNER "${CURRENT_INSTALLED_DIR}/tools/gobject-introspection/g-ir-scanner${VCPKG_TARGET_EXECUTABLE_SUFFIX}" PARENT_SCOPE)
        list(REMOVE_ITEM ARGN "GIR_SCANNER")
    endif()
    if(NOT ARGN STREQUAL "")
        message(FATAL_ERROR "Unsupported arguments: ${ARGN}")
    endif()
endfunction()

if(NOT PYTHON3)
    vcpkg_get_gobject_introspection_python(PYTHON3)
endif()
