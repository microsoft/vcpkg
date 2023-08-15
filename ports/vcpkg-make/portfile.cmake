set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)
file(COPY "${CMAKE_CURRENT_LIST_DIR}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE 
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/portfile.cmake"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg.json"
    )

vcpkg_install_copyright("${VCPKG_ROOT_DIR}/LICENSE.txt")

