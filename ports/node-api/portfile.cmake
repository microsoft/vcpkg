
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(nodejs_arch "x64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  set(nodejs_arch "ia32")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  set(nodejs_arch "arm64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  set(nodejs_arch "arm")
else()
  message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(NODEJS_VERSION 18.12.1)

set(headers_url "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-headers.tar.gz")

# download headers
vcpkg_download_distfile(
  out_headers
  URLS "${headers_url}"
  FILENAME "node-v${NODEJS_VERSION}-headers.tar.gz"
  SHA512 ee66d0c03d2e48046a42616abf7639a3983e7db24c04d8643b9141cb9209a50643e31873c5a4918853a4344e822d653480558510a4db9a2ab481396891d79917
)

# extract headers
vcpkg_extract_source_archive(
  OUT_SOURCE_PATH
  ARCHIVE "${out_headers}"
)

set(suffix "include/node")
set(source_path "${OUT_SOURCE_PATH}/${suffix}")


# Copy files to the build tree
file(COPY "${source_path}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

#if(NODE_API_LIB)
#  file(COPY "${NODE_API_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
#  file(COPY "${NODE_API_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
#endif()
#if(NODE_API_SRC)
#  file(COPY "${NODE_API_SRC}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
#endif()

# Handle copyright
#file(INSTALL "${NODEJS_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Copy ./unofficial-node-api-config.cmake to ${CURRENT_PACKAGES_DIR}/share/node-api
#file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-node-api-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")