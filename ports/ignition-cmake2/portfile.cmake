set(PACKAGE_VERSION "2.17.1")

ignition_modular_library(NAME cmake
                         VERSION ${PACKAGE_VERSION}
                         SHA512 871a32e9ca5314caa5f25b4135b430e7be829f7afd12ba98ea4524ee758c7ca7ebf64a9e567c6dbc285c497320cd0fe1e69f8d891343b869344726b32dbdc3ee
                         PATCHES
                            add-pkgconfig-and-remove-privatefor-limit.patch)

# Install custom usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
