# Explicitly disable cross-compilation until the upstream discussion
# https://github.com/ignitionrobotics/ign-msgs/issues/34 is solved
vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "linux" "uwp") 

include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

# This port needs  to generate protobuf messages with a custom plugin generator,
# so it needs to have in Windows the relative protobuf dll available in the PATH
set(path_backup $ENV{PATH})
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/bin)
vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/debug/bin)

ignition_modular_library(NAME msgs
                         VERSION "5.1.0"
                         SHA512 db485f737c465b310602342a1a751c561473e330eb18d1b322b32d13de246536fe6a7efdf245faaaa9be1c9bfce662b2d39d1bb7cffc37e52690893cb47cc2ee
                         PATCHES
                           "01-protobuf.patch")

# Restore old path
set(ENV{PATH} ${path_backup})
