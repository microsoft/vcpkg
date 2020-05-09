include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

ignition_modular_library(NAME transport
                         VERSION "8.0.0"
                         SHA512 ab1bae994a8676864ceb78b87f2258b8ed22036aed87e815fc22f830edd8b087d1ef0406dc0d053ea823d95b5fb765c4867d27ce5653f1d685001aab0cf0ec03
                         # This can  be removed when the pc file of libuuid on Windows is fixed
                         DISABLE_PKGCONFIG_INSTALL)
