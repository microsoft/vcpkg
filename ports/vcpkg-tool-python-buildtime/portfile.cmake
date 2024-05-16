set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

file(INSTALL
        "${CMAKE_CURRENT_LIST_DIR}/download.json"
        "${CMAKE_CURRENT_LIST_DIR}/pip_constraints.txt"
        "${CMAKE_CURRENT_LIST_DIR}/pip_prepare_candidate.diff"
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg-tool-python-buildtime.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(FILE_LIST "${VCPKG_ROOT_DIR}/LICENSE.txt")
