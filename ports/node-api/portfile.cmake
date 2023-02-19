vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node-api-headers
  REF ecefbdd00f2cd04eaf1c06b6481abe9b031b5f0b
  SHA512 66e8464e74bcaa5e7d9987f5e1101b8df7b6cf4752d0df52a6f26b6897c6022fd39268dac7edc489887d2e9fd0fc6161077dcd55ba51995cbef59e9bbe94c54c
  HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME "node")

# get_filename_component(DIST_FILENAME "${DIST_URL}" NAME)

# if(out_win_lib)
#   # nodejs requires the same node.lib to be used for both debug and release builds
#   file(COPY "${out_win_lib}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
#   file(COPY "${out_win_lib}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
# endif()

# # download dist
# vcpkg_download_distfile(
#   out_dist
#   URLS "${DIST_URL}"
#   FILENAME "${DIST_FILENAME}"
#   SHA512 "${SHA512}"
# )

# # extract dist
# vcpkg_extract_source_archive(
#   OUT_SOURCE_PATH
#   ARCHIVE "${out_dist}"
# )

# # copy headers
# set(suffix "include/node")
# set(source_path "${OUT_SOURCE_PATH}/${suffix}")
# file(COPY "${source_path}" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")

# we do not take the license from the dist file because it is not included as we download the headers only
set(license_url "https://raw.githubusercontent.com/nodejs/node/v18.12.1/LICENSE")
vcpkg_download_distfile(
  out_license
  URLS "${license_url}"
  FILENAME "LICENSE"
  SHA512 2d79b49a12178a078cf1246ef7589d127189914403cd6f4dfe277ced2b3ef441a6e6ee131f1c75f996d1c1528b7e1ae332e83c1dc44580b2b51a933ed0c50c48
)
file(INSTALL "${out_license}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-node-api-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-node-api-config.cmake" @ONLY)
