vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

set(SHA512 0)

if(VCPKG_TARGET_IS_WINDOWS)
  set(SHA512 ee66d0c03d2e48046a42616abf7639a3983e7db24c04d8643b9141cb9209a50643e31873c5a4918853a4344e822d653480558510a4db9a2ab481396891d79917)
  set(DIST_URL "https://nodejs.org/dist/v${VERSION}/node-v${VERSION}-headers.tar.gz")
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    vcpkg_download_distfile(
      out_win_lib
      URLS "https://nodejs.org/dist/v${VERSION}/win-x64/node.lib"
      FILENAME "node.lib"
      SHA512 95c4b053bf88f758b6124b4a576719901545485613767f1ab996bb019ea7bb0d303c511b357f830e5a14d463dd74c6b412f126103f21d12e31ca00c7de86d853
    )
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    vcpkg_download_distfile(
      out_win_lib
      URLS "https://nodejs.org/dist/v${VERSION}/win-x86/node.lib"
      FILENAME "node.lib"
      SHA512 0baa54a7870088a3290f817f6362446d304e8710ee36f99075925d110bce5c1eac377aa5c4ed6cf30161f98f39032d848eeb8d459add57b1c6458b8c91c72073
    )
  endif()
elseif(VCPKG_TARGET_IS_OSX)
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(SHA512 8eb1713afdce23b0e8408d81aa47b3ea0955de328105d666a57efef8955b286c707c107377cff36164d8455558829ab65567b9cbe5997085afc841d95128fcd5)
    set(DIST_URL "https://nodejs.org/dist/v${VERSION}/node-v${VERSION}-darwin-arm64.tar.gz")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(SHA512 ffe7e878fd5e424b0ff0d2e7db5e9c02f283792df2f1a748bd6381226701bcd9f93ae48f88d295412afb10d1c924ca068f70aba9857236c8893a2b812eacf248)
    set(DIST_URL "https://nodejs.org/dist/v${VERSION}/node-v${VERSION}-darwin-x64.tar.gz")
  endif()
elseif(VCPKG_TARGET_IS_LINUX)
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(SHA512 f137a0dba52ded9f2f6b304c5f41fd2c75ba069ee31cfb89811b14254552c0d5ba10890f7001e64e8a6fee277302cb0ba915e0a417c047577384ac495c4ff447)
    set(DIST_URL "https://nodejs.org/dist/v${VERSION}/node-v${VERSION}-linux-x64.tar.gz")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(SHA512 a0b2f522b0ecdc4b642f3104fd2eb08b8dfa6dc2b116b5a331722b8c6d96b2b6d5df0e691ef2b56e0463e1f30d37c98c686c5d306e1aa8cd927b306c4eef0770)
    set(DIST_URL "https://nodejs.org/dist/v${VERSION}/node-v${VERSION}-linux-arm64.tar.gz")
  endif()
endif()

get_filename_component(DIST_FILENAME "${DIST_URL}" NAME)

if(out_win_lib)
  # nodejs requires the same node.lib to be used for both debug and release builds
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

# we do not take the license from the dist file because for windows it is not included as we download the headers only
set(license_url "https://raw.githubusercontent.com/nodejs/node/v18.12.1/LICENSE")
vcpkg_download_distfile(
  out_license
  URLS "${license_url}"
  FILENAME "LICENSE"
  SHA512 2d79b49a12178a078cf1246ef7589d127189914403cd6f4dfe277ced2b3ef441a6e6ee131f1c75f996d1c1528b7e1ae332e83c1dc44580b2b51a933ed0c50c48
)
file(INSTALL "${out_license}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# copy ./unofficial-node-api-config.cmake to ${CURRENT_PACKAGES_DIR}/share/node-api
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-node-api-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")
