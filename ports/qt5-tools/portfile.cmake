include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)

vcpkg_list(SET OPTIONS)
if("qdoc" IN_LIST FEATURES)
    set(ENV{LLVM_INSTALL_DIR} "${CURRENT_INSTALLED_DIR}")
    vcpkg_list(APPEND OPTIONS -feature-qdoc)
else()
    vcpkg_list(APPEND OPTIONS -no-feature-qdoc)
endif()

qt_submodule_installation(
    PATCHES
        fix-pkgconfig-qt5uiplugin-not-found.patch
        libclang.patch
    BUILD_OPTIONS
        ${OPTIONS}
)

if(EXISTS "${CURRENT_INSTALLED_DIR}/plugins/platforms/qminimal${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
    file(INSTALL "${CURRENT_INSTALLED_DIR}/plugins/platforms/qminimal${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/plugins/platforms")
endif()
