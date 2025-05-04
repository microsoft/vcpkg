set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
file(INSTALL "${VCPKG_ROOT_DIR}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
