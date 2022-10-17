file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_add_ts_parser.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.in"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(COPY "${CURRENT_INSTALLED_DIR}/share/tree-sitter/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
