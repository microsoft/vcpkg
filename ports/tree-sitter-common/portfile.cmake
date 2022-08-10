file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_ts_parser_add.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.in"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "")

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
