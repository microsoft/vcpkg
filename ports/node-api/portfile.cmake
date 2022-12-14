set(NODEJS_VERSION 18.12.1)

set(SHA512 0)

if(VCPKG_TARGET_IS_WINDOWS)
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(SHA512 0)
    set(DIST_URL "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-headers.tar.gz")
    vcpkg_download_distfile(
      out_win_lib
      URLS "https://nodejs.org/dist/v${NODEJS_VERSION}/win-x64/node.lib"
      FILENAME "node.lib"
      SHA512 0
    )
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(SHA512 0)
    set(DIST_URL "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-headers.tar.gz")
    vcpkg_download_distfile(
      out_win_lib
      URLS "https://nodejs.org/dist/v${NODEJS_VERSION}/win-x86/node.lib"
      FILENAME "node.lib"
      SHA512 0
    )
  endif()
elseif(VCPKG_TARGET_IS_OSX)
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(SHA512 8eb1713afdce23b0e8408d81aa47b3ea0955de328105d666a57efef8955b286c707c107377cff36164d8455558829ab65567b9cbe5997085afc841d95128fcd5)
    set(DIST_URL "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-darwin-arm64.tar.gz")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(SHA512 ffe7e878fd5e424b0ff0d2e7db5e9c02f283792df2f1a748bd6381226701bcd9f93ae48f88d295412afb10d1c924ca068f70aba9857236c8893a2b812eacf248)
    set(DIST_URL "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-darwin-x64.tar.gz")
  endif()
elseif(VCPKG_TARGET_IS_LINUX)
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(SHA512 f137a0dba52ded9f2f6b304c5f41fd2c75ba069ee31cfb89811b14254552c0d5ba10890f7001e64e8a6fee277302cb0ba915e0a417c047577384ac495c4ff447)
    set(DIST_URL "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.gz")
  endif()
endif()

get_filename_component(DIST_FILENAME "${DIST_URL}" NAME)

if(out_win_lib)
  file(COPY "${out_win_lib}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  file(COPY "${out_win_lib}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

# download dist
vcpkg_download_distfile(
  out_dist
  URLS "${DIST_URL}"
  FILENAME "${DIST_FILENAME}"
  SHA512 "${SHA512}"
)

# extract dist
vcpkg_extract_source_archive(
  OUT_SOURCE_PATH
  ARCHIVE "${out_dist}"
)

# copy headers
set(suffix "include/node")
set(source_path "${OUT_SOURCE_PATH}/${suffix}")
file(COPY "${source_path}" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")

# copy license
file(INSTALL "${OUT_SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# copy ./unofficial-node-api-config.cmake to ${CURRENT_PACKAGES_DIR}/share/node-api
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-node-api-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")