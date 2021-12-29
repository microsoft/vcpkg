
file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/boost-modular-headers.cmake
    ${CMAKE_CURRENT_LIST_DIR}/usage
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
