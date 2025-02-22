string(REGEX MATCH "^[1-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}${VERSION_MAJOR}_${VERSION}
   VERSION ${VERSION}
   SHA512 734d4c2eccf42a3a5a665611c44ccb450bf290763bcf8dc169b16c0c5c5c7d7be6b3cb69c69a5ef64a502b411fdb1461f036c660d8d9188146e61cf8f4beead8
   OPTIONS 
   PATCHES
      uuid-osx.patch
)

# preserve the original port behavior
file(COPY "${CURRENT_PACKAGES_DIR}/share/${PORT}/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}${VERSION_MAJOR}/")
