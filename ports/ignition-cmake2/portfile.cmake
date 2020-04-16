include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

set(PACKAGE_VERSION "2.1.1")

ignition_modular_library(NAME cmake
                         VERSION ${PACKAGE_VERSION}
                         SHA512 4dce0ef477b737a217179478262ef9c9eafffbd6933023b43a3506ea76502955ab5ae8a94d779c13ad4ca15849cdfbe9f9d696af2ccc102522239040b9540fd9)

# Permit empty include folder
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

# Remove unneccessary directory, as ignition-cmake is a pure CMake package
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Install custom usage
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
