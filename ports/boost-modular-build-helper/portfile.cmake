set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(
    COPY
        ${CMAKE_CURRENT_LIST_DIR}/boost-modular-build.cmake
        ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
        ${CMAKE_CURRENT_LIST_DIR}/Jamroot.jam.in
        ${CMAKE_CURRENT_LIST_DIR}/nothing.bat
        ${CMAKE_CURRENT_LIST_DIR}/usage
        ${CMAKE_CURRENT_LIST_DIR}/user-config.jam.in
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/boost-build
)