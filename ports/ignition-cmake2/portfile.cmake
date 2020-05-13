include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

set(PACKAGE_VERSION "2.2.0")

ignition_modular_library(NAME cmake
                         VERSION ${PACKAGE_VERSION}
                         SHA512 079b6d0cc5e2de83cf01f5731dd4e2e55e18e46c7506b6267a19a230fbbaa7b89053be4b42ca21584cf7fdd64de1d6305c7bc16fa3e0c5751b098fd0e5b98149)

# Install custom usage
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
