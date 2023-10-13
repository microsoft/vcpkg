set(PACKAGE_NAME cmake)

ignition_modular_library(
    NAME ${PACKAGE_NAME}
    REF ${PORT}_${VERSION}
    VERSION ${VERSION}
    SHA512 59d6f90561e762c00035aae273420bc3d6a24af47b5d2914cd8547146f63919bc4c3e33e6c0942dc89bc75925cebff1bcbbf18e3239220ebc6bb194326c3197a
)

# Install custom usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
