set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
file(COPY_FILE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/libssh2.pc" "${CURRENT_BUILDTREES_DIR}/libssh2.pc.log")
message(FATAL_ERROR STOP)
