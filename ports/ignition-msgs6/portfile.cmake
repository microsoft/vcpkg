# Cross-compilation is explicitly disabled until the upstream discussion
# https://github.com/ignitionrobotics/ign-msgs/issues/34 is solved

include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

ignition_modular_library(NAME msgs
                         VERSION "6.0.0"
                         SHA512 d1d6f6602ae33ec95b36c5df7815b06970f349492ef0309d8aacbaf2dca0c3e7314bbd64890a2554485fbd52f148a90b7bf54dceb0b3a1dd40eeb1f5bdb9613c)
