set(PACKAGE_NAME cmake)

ignition_modular_library(NAME ${PACKAGE_NAME}
                         REF ${PORT}_${VERSION}
                         VERSION ${VERSION}
                         SHA512 99fb6a137b8a913b49e7881e9b2c96ca1ae03fb48cfa30f635a69396ccb0eb108abb8a925fd85dc46f3b10f88758675da53eb6cae3325eabeac5e6bee6f54d91
                         PATCHES
                        )

# Install custom usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
