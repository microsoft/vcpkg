string(REGEX MATCH "^[1-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}${VERSION_MAJOR}_${VERSION}
   VERSION ${VERSION}
   SHA512 6a31719441c7ea835007d82b6aea99b10fa124ebad71683b8c1c58c41b435d4801e016464dc30d760cc9464e642dab4ff910375f5244ebf7c565845174e65cbf
   OPTIONS 
   PATCHES
      remove_docs.patch
)

# preserve the original port behavior
file(COPY "${CURRENT_PACKAGES_DIR}/share/${PORT}/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}${VERSION_MAJOR}/")
