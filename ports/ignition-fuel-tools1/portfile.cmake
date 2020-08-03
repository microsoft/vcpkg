include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

ignition_modular_library(NAME fuel-tools
                         VERSION "1.2.0"
                         CMAKE_PACKAGE_NAME ignition-fuel_tools1
                         SHA512 a656fed74fb2138b3bcf7d35b25ad06da95cfb9a3ad7ded2c9c54db385f55ea310fd1a72dcf6400b0a6199e376c1ba2d11ee2a08c66e3c2cc8b2ee1b25406986
                         # Ensure yaml is correctly linked (backport of https://bitbucket.org/ignitionrobotics/ign-fuel-tools/pull-requests/103/use-yaml_target-instead-of-yaml-yaml/diff)
                         PATCHES link-correct-yaml-target.patch
                         # This can  be removed when the pc file of curl is fixed
                         DISABLE_PKGCONFIG_INSTALL
                         )
