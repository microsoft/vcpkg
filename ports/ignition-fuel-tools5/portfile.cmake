include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

ignition_modular_library(NAME fuel-tools
                         VERSION "5.0.0"
                         CMAKE_PACKAGE_NAME ignition-fuel_tools5
                         SHA512 -1
                         # Ensure yaml is correctly linked (backport of https://bitbucket.org/ignitionrobotics/ign-fuel-tools/pull-requests/103/use-yaml_target-instead-of-yaml-yaml/diff)
                         # PATCHES link-correct-yaml-target.patch
                         # This can  be removed when the pc file of curl is fixed
                         DISABLE_PKGCONFIG_INSTALL
                         )
