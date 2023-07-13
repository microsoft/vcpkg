ignition_modular_library(NAME fuel-tools
                         VERSION "1.2.0"
                         CMAKE_PACKAGE_NAME ignition-fuel_tools1
                         SHA512 44ce9215231981f393cf1f6f83071e3f1c5d29bef4fab8d6483eb136b6e2a2e4273e85845f8b2336c4d50ac5fdcc6eb028a972baa0950083c8fa700f85cc7078
                         # Ensure yaml is correctly linked (backport of https://bitbucket.org/ignitionrobotics/ign-fuel-tools/pull-requests/103/use-yaml_target-instead-of-yaml-yaml/diff)
                         PATCHES link-correct-yaml-target.patch
                         # This can  be removed when the pc file of curl is fixed
                         DISABLE_PKGCONFIG_INSTALL
                         )
