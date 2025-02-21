set(PACKAGE_NAME transport)

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 734d4c2eccf42a3a5a665611c44ccb450bf290763bcf8dc169b16c0c5c5c7d7be6b3cb69c69a5ef64a502b411fdb1461f036c660d8d9188146e61cf8f4beead8
   OPTIONS 
   PATCHES
      uuid-osx.patch
)
