if(VCPKG_CROSSCOMPILING)
    message(FATAL_ERROR "vcpkg-rust is a host-only port; please mark it as a host port in your dependencies.")
endif()

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_rust_install.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${VCPKG_ROOT_DIR}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)
