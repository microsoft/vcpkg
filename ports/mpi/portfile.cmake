set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if (VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${CURRENT_INSTALLED_DIR}/share/msmpi/mpi-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME vcpkg-cmake-wrapper.cmake)
elseif()
    configure_file("${CURRENT_PORT_DIR}/mpi.pc.in" "${CURRENT_PACKAGES_DIR}/share/pkgconfig/mpi.pc" @ONLY)
endif()
