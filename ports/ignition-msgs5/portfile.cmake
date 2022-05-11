# Cross-compilation is disabled until the upstream discussion
# https://github.com/ignitionrobotics/ign-msgs/issues/34 is solved

include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

ignition_modular_library(NAME msgs
                         VERSION "5.3.0"
                         SHA512 55c167d00b60ae6da0144a9495e9ac8aed61fcbdc61e057e75d31261e335c573543d60e28a7dc195a7c9849c5c6eb0e088d4f4e79fd927e83470a3f1fabef60e
                         PATCHES
                         "01-protobuf.patch")
