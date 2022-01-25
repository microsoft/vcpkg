file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_qmake_configure.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/copyright"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
