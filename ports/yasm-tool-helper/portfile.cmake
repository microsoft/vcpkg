set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/yasm-tool-helper.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/yasm-tool-helper.cmake"
    @ONLY)
