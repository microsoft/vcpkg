file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/fixcmake.py
    ${CMAKE_CURRENT_LIST_DIR}/qt_modular_library.cmake
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/qt5modularscripts
)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
