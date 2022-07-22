ignition_modular_library(NAME transport
                         VERSION "9.0.0"
                         SHA512 9add7a8d3a43a17b1b71e7d7d9320909057c1f79880bd969baa99949709cdbb63f00f0735990891358bb29efd9c0ab8b6725b7c340c324b9266dcc9b73d767d4
                         # This can be removed when the pc file of sqlite3 is available ( https://github.com/microsoft/vcpkg/issues/14327 )
                         DISABLE_PKGCONFIG_INSTALL
                         PATCHES
                            uuid-osx.patch
                         )
