include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

set(PACKAGE_VERSION "2.5.0")

ignition_modular_library(NAME cmake
                         VERSION ${PACKAGE_VERSION}
                         SHA512 dc546e5e4deabba12faec5fb0162309dfce9b429a6bbd6637c058acdda3eb4fa1e44e9b71f55603d0cff77550117dafc3fc8475621ede65fa8aa915254beb463
                         PATCHES FindGTS.patch)

# Install custom usage
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
