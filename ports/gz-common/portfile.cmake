string(REGEX MATCH "^[0-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}${VERSION_MAJOR}_${VERSION}
   VERSION ${VERSION}
   SHA512 0c652285b32d2d2f781595416fd80d6e52a6b765ba968d0018accc3688f4ee9d6ce62dbea74b98fa43ea40641c47020246e13645eac7940aa483057c958d3807
   PATCHES
      gz-utils3-log.diff
      gz_remotery_vis.patch
      pthread.diff
      003-include-chrono.patch
      gdal-3.11.diff
)
