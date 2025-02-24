string(REGEX MATCH "^[1-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

ignition_modular_library(NAME ${PACKAGE_NAME}
                         REF ${PORT}${VERSION_MAJOR}_${VERSION}
                         VERSION ${VERSION}
                         SHA512 2e896e7106591a427fd5a732ba7dbfb329a3c0ec70601f5bf9b2390907e37b41837fd06696f4a93fb4ccc16a94a0221e4734e59f9fb1c7e5a016a076800d8214
                         PATCHES
                        )

# preserve the original port behavior
file(COPY "${CURRENT_PACKAGES_DIR}/share/${PORT}/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}${VERSION_MAJOR}")
