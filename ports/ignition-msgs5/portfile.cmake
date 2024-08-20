# Cross-compilation is disabled until the upstream discussion
# https://github.com/ignitionrobotics/ign-msgs/issues/34 is solved

ignition_modular_library(NAME msgs
                         VERSION "5.3.0"
                         SHA512 645ae5317fb4c3c1b452e98c3581363fc939b5b963dae8a2097bcee97584819bd80357397d88728c5917142dd4ac9beecc335862df44fc06a46d8aa62c54e389
                         PATCHES
                         "01-protobuf.patch"
                         "02-Add_std_string.patch"
                         "03-protobuf-version.patch")
