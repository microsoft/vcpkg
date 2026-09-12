include("${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake")

set(OPTIONS -system-assimp)

x_vcpkg_pkgconfig_get_modules(PREFIX assimp MODULES assimp LIBS)

set(OPT_REL "ASSIMP_LIBS=${assimp_LIBS_RELEASE}")
set(OPT_DBG "ASSIMP_LIBS=${assimp_LIBS_DEBUG}")

qt_download_submodule(
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        assimp-config-test-cxx17.patch
)

if(QT_UPDATE_VERSION)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()
    qt_build_submodule(
        "${SOURCE_PATH}"
        BUILD_OPTIONS ${OPTIONS}
        BUILD_OPTIONS_RELEASE ${OPT_REL}
        BUILD_OPTIONS_DEBUG ${OPT_DBG}
    )

    qt_install_copyright("${SOURCE_PATH}")
endif()

vcpkg_restore_env_variables(VARS QMAKEFLAGS)
