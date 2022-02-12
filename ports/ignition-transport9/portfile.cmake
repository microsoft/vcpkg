include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

ignition_modular_library(NAME transport
                         VERSION "9.0.0"
                         SHA512 c3edb7a8a063b4aa5826838ae08c8ec2b3d14563492022df632a719409c95272f4f6a43d91f0c317e44b85921b5aedc1685670b81a7baa949f01af3b3534d76e
                         # This can be removed when the pc file of sqlite3 is available ( https://github.com/microsoft/vcpkg/issues/14327 )
                         DISABLE_PKGCONFIG_INSTALL
                         PATCHES
                            uuid-osx.patch
                         )
