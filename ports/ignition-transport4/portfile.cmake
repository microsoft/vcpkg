include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

ignition_modular_library(NAME transport
                         VERSION "4.0.0"
                         SHA512 d4125044c21fdd6754f3b8b06f372df3f858080d5d33e97ed7a8ef8f6fb9857d562082aad41c89ea9146a33b1c3814305d33c5c8f8bcde66a16477b4a01655b4
                         # This can  be removed when the pc file of libuuid on Windows is fixed
                         DISABLE_PKGCONFIG_INSTALL
                         PATCHES
                            uuid-osx.patch
                         )
