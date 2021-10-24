if(VCPKG_CROSSCOMPILING)
    # make FATAL_ERROR in CI when issue #16773 fixed
    message(WARNING "vcpkg-qmake is a host-only port; please mark it as a host port in your dependencies.")
endif()

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_qmake_configure.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/copyright"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
