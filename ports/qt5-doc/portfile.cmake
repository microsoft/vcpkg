set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_BUILD_TYPE release)

include("${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake")
qt_submodule_installation()

vcpkg_build_qmake(TARGETS docs SKIP_MAKEFILES BUILD_LOGNAME docs)
qt_fix_makefile_install("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")
vcpkg_build_qmake(TARGETS install_docs SKIP_MAKEFILES BUILD_LOGNAME install-docs)
if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/share/qt5/doc/qtdoc.qch")
    message(FATAL_ERROR "Failed to install qtdoc.qch.")
endif()
