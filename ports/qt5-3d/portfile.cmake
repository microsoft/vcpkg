include("${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake")

set(OPTIONS -system-assimp)

x_vcpkg_pkgconfig_get_modules(PREFIX assimp MODULES assimp LIBS)

set(OPT_REL "ASSIMP_LIBS=${assimp_LIBS_RELEASE}")
set(OPT_DBG "ASSIMP_LIBS=${assimp_LIBS_DEBUG}")

qt_submodule_installation(BUILD_OPTIONS ${OPTIONS} BUILD_OPTIONS_RELEASE ${OPT_REL} BUILD_OPTIONS_DEBUG ${OPT_DBG})
