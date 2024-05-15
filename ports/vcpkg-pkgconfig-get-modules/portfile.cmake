set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

file(COPY
    "${CURRENT_PORT_DIR}/vcpkg-port-config.cmake"
    "${CURRENT_PORT_DIR}/x_vcpkg_pkgconfig_get_modules.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${VCPKG_ROOT_DIR}/LICENSE.txt")
