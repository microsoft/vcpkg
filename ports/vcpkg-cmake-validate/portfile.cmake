file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/z_vcpkg_cmake_validate_build.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_cmake_validate.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/copyright"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/project/CMakeLists.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/project"
)
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
