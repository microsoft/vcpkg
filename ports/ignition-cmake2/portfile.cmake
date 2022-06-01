set(PACKAGE_VERSION "2.5.0")

ignition_modular_library(NAME cmake
                         VERSION ${PACKAGE_VERSION}
                         OUT_SOURCE_PATH SOURCE_PATH
                         SHA512 e39ed44ae6f7ccc338412f466f1257f88989e0818bee801ddbe09350e906cd9ce709be24356310fdbfde22d1b5b5846fed0aa794c06dcf7caf82748a07b428d6
                         PATCHES FindGTS.patch)

# For ignition-common3
file(INSTALL "${SOURCE_PATH}/cmake/FindGTS.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

# Install custom usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
