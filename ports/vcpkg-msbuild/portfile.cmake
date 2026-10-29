file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_msbuild.props.in"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_msbuild.targets.in"
    "${CMAKE_CURRENT_LIST_DIR}/z_vcpkg_msbuild_create_props.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_msbuild_install.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${VCPKG_ROOT_DIR}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)
