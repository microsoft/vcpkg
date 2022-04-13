include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

ignition_modular_library(NAME math
                         VERSION "6.6.0"
                         SHA512 1b5f59b45256daa81cbfb7da4727200d0d6cb4a75fbc3b83b512c18ec6307b5bd78b8ee7a84f0f8a8c334717a1480766f62658bd213e9021c09c0ed22caa921d
                         PATCHES fix-isspace.patch)
