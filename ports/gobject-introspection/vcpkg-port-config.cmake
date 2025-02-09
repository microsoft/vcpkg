if(NOT PYTHON3)
    # host-triplet python interpreter for giscanner module compatibility
    include("${CURRENT_HOST_INSTALLED_DIR}/share/python3/vcpkg-port-config.cmake")
    vcpkg_get_vcpkg_installed_python(PYTHON3 INTERPRETER)
endif()
