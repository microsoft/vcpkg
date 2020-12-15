include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

ignition_modular_library(NAME transport
                         VERSION "8.1.0"
                         SHA512 eb64f18721190fcb79a5b45746fd44fa24274c6fe6c5021dd9306c15a327873377d07d4aa770633982038b84da650d3d0c8a56169222c0c88fa1318314fc4529
                         # This can be removed when the pc file of sqlite3 is available ( https://github.com/microsoft/vcpkg/issues/14327 )
                         DISABLE_PKGCONFIG_INSTALL)
