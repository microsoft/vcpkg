set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${VCPKG_ROOT_DIR}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_find_acquire_python3_interpreter.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
