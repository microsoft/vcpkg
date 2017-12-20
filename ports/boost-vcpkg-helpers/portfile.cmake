
file(
    COPY
        ${CMAKE_CURRENT_LIST_DIR}/boost-modular.cmake
        ${CMAKE_CURRENT_LIST_DIR}/Jamroot.jam
        ${CMAKE_CURRENT_LIST_DIR}/nothing.bat
        ${CMAKE_CURRENT_LIST_DIR}/user-config.jam
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/boost-vcpkg-helpers
)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
