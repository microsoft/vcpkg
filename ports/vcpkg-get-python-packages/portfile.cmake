if(VCPKG_CROSSCOMPILING)
    message(FATAL_ERROR "${PORT} is a host-only port; please mark it as a host port in your dependencies.")
endif()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/copyright"
    "${CMAKE_CURRENT_LIST_DIR}/x_vcpkg_get_python_packages.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
