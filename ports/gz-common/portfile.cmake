string(REGEX MATCH "^[0-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}${VERSION_MAJOR}_${VERSION}
   VERSION ${VERSION}
   SHA512 e134d4ac034535652ad10aa29250987e35a0ecde1e3a48d6588a7c815ace6a3370c5f04876c2f72d499363722983d842e35b3133c83ba0c7678c4aaf97044a9a
   PATCHES
      gz-utils3-log.diff
      gz_remotery_vis.patch
      pthread.diff
      gdal-3.11.diff
)
