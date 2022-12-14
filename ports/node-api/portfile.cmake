
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(nodejs_arch "x64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  set(nodejs_arch "x86")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  set(nodejs_arch "arm64")
else()
  message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
  set(nodejs_os "win")
elseif(VCPKG_TARGET_IS_OSX)
  set(nodejs_os "darwin")
elseif(VCPKG_TARGET_IS_LINUX)
  set(nodejs_os "linux")
else()
  message(FATAL_ERROR "Unsupported OS")
endif()

set(NODEJS_VERSION 18.12.1)

# prepare vars for dist download
set(dist_urls)
list(APPEND dist_urls "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-${nodejs_os}-${nodejs_arch}.zip")
list(APPEND dist_urls "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-${nodejs_os}-${nodejs_arch}.tar.gz")

set(nodejs_sha512_darwin_arm64 8eb1713afdce23b0e8408d81aa47b3ea0955de328105d666a57efef8955b286c707c107377cff36164d8455558829ab65567b9cbe5997085afc841d95128fcd5)
set(nodejs_sha512_darwin_x64 ffe7e878fd5e424b0ff0d2e7db5e9c02f283792df2f1a748bd6381226701bcd9f93ae48f88d295412afb10d1c924ca068f70aba9857236c8893a2b812eacf248)
set(nodejs_sha512_linux_x64 f137a0dba52ded9f2f6b304c5f41fd2c75ba069ee31cfb89811b14254552c0d5ba10890f7001e64e8a6fee277302cb0ba915e0a417c047577384ac495c4ff447)
set(nodejs_sha512_win_x64 0)
set(nodejs_sha512_win_x86 0)
set(nodejs_sha512_win_arm64 0)

set(SHA512 "${nodejs_sha512_${nodejs_os}_${nodejs_arch}}")
if ("${SHA512}" STREQUAL "")
  message(FATAL_ERROR "No SHA512 specified for ${nodejs_os} ${nodejs_arch}")
endif()

# download dist
vcpkg_download_distfile(
  out_dist
  URLS "${dist_urls}"
  FILENAME "node-v${NODEJS_VERSION}-${nodejs_os}-${nodejs_arch}.tar.gz"
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