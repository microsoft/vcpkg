string(REGEX MATCH "^[0-9]+" VERSION_MAJOR "${VERSION}")
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE "${PORT}")
set(PACKAGE_NAME "${CMAKE_MATCH_1}")

ignition_modular_library(
   NAME "${PACKAGE_NAME}"
   REF "${PORT}${VERSION_MAJOR}_${VERSION}"
   VERSION "${VERSION}"
   SHA512 fb94b496ce351771acaaff9e7476ff09e3536a3bbfd63404350a3be4ea32d52aec7564c9ef97c99c696342eefa2e0e4efa58f4d1bb0d70ea18677785f7b5d9ca
   PATCHES
      gz-utils3-log.diff
      gz_remotery_vis.patch
      pthread.diff
      gdal-3.11.diff
)
