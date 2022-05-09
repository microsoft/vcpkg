set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(VCPKG_POLICY_CMAKE_SCRIPT_HELPER enabled)
    set(FUNCTION_NAME x_vcpkg_find_fortran)
    set(PORT_IMPL vcpkg-fortran-flang)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(PORT_IMPL vcpkg-fortran-ifort)
    endif()
    #if(VCPKG_CROSSCOMPILING)
    #    message(FATAL_ERROR "${PORT} is a host-only port; please mark it as a host port in your dependencies.")
    #endif()

    #file(COPY
    #    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

    configure_file("${VCPKG_ROOT_DIR}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/coypright" COPYONLY)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
endif()