# Random123 - Header-only library

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO "DEShawResearch/random123"
  REF "v1.14.0"
  SHA512 1c7d139193f5404e5d14d229f55e0a14b11de596a4cfbf0a39c1419f5ae146055dccc61e9430f724a2d7c1efb8bd01edb72866d4f4705508fcc6ebda6e90e91e
  HEAD_REF "main"
  )

# Copy the headers that define this package to the install location.
file(GLOB header_files 
    "${SOURCE_PATH}/include/Random123/*.h"
    "${SOURCE_PATH}/include/Random123/*.hpp") 
file(COPY ${header_files}
    "${SOURCE_PATH}/include/Random123/features"
    "${SOURCE_PATH}/include/Random123/conventional"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/Random123")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" 
    RENAME copyright)
