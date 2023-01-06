if(NOT TARGET_TRIPLET STREQUAL HOST_TRIPLET)
    # make FATAL_ERROR in CI when issue #16773 fixed
    message(WARNING "vcpkg-pkgconfig-get-modules is a host-only port; please mark it as a host port in your dependencies.")
endif()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${VCPKG_ROOT_DIR}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/x_vcpkg_pkgconfig_get_modules.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/x_vcpkg_pkgconfig_get_modules.cmake" @ONLY)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
