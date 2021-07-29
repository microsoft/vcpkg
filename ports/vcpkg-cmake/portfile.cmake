if(NOT TARGET_TRIPLET STREQUAL _HOST_TRIPLET)
    # make FATAL_ERROR in CI when issue #16773 fixed
    message(WARNING "vcpkg-cmake is a host-only port; please mark it as a host port in your dependencies.")
endif()

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_cmake_configure.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_cmake_build.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_cmake_install.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_cmake_get_vars.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/cmake_get_vars"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/copyright"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
