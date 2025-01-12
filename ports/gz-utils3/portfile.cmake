set(PACKAGE_NAME utils)

ignition_modular_library(NAME ${PACKAGE_NAME}
                         REF ${PORT}_${VERSION}
                         VERSION ${VERSION}
                         SHA512 abac6e68ccb9b036dab4a49e5c9c64045045311595ac5d7a96222f8368d8fe4b007fe274abe45b877df19dce12bb08350e6600a28f040bb09acc3f15a5851bd2
                         PATCHES
                        )
