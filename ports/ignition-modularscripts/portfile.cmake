file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/ignition_modular_library.cmake
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/ignitionmodularscripts
)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/ignitionmodularscripts/copyright "")

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
