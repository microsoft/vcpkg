include(vcpkg_common_functions)

include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

ignition_modular_library(NAME fuel-tools
                         VERSION "1.2.0"
                         CMAKE_PACKAGE_NAME ignition-fuel_tools1
                         SHA512 5ed8d1429e1f5c0716e06840a4163f7e79a614cf7b6ff326adb69d35639e3ec5f1862edc41c6dc0bd21b16db6d13bee509831a66b10ca2ae3999649f1554a68e
                         # Ensure yaml is correctly linked (backport of https://bitbucket.org/ignitionrobotics/ign-fuel-tools/pull-requests/103/use-yaml_target-instead-of-yaml-yaml/diff)
                         PATCHES link-correct-yaml-target.patch)
