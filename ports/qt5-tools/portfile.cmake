include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)

qt_submodule_installation(
    PATCHES
        "fix-pkgconfig-qt5uiplugin-not-found.patch"
)

if(EXISTS "${CURRENT_INSTALLED_DIR}/plugins/platforms/qminimal${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
    file(INSTALL "${CURRENT_INSTALLED_DIR}/plugins/platforms/qminimal${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/plugins/platforms")
endif()
