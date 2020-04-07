include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

set(PACKAGE_VERSION "2.1.1")

ignition_modular_library(NAME cmake
                         VERSION ${PACKAGE_VERSION}
                         SHA512 4d22a45ccc9582c7e4b370b884511782d1629fa3e257dd92300388b5050d22fa63dd4a6ef8942abb9ebbc300df4cd526d1d8a7088a92b0073e152c16c7b97e2b)

# Permit empty include folder
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

# Remove unneccessary directory, as ignition-cmake is a pure CMake package
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Install custom usage
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
