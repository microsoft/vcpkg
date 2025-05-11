set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(INSTALL "${CURRENT_PORT_DIR}/mutable" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
foreach(name IN LISTS FEATURES)
    file(GLOB blobs "${CURRENT_PORT_DIR}/../${name}-*.dat")
    file(INSTALL ${blobs} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endforeach()
