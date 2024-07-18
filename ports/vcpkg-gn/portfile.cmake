set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)
set(VCPKG_POLICY_SKIP_COPYRIGHT_CHECK enabled)

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_gn_common.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_gn_configure.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_gn_install.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_gn_export_cmake.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-port-targets.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-port-targets-details.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
