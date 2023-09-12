vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node-addon-api
  REF "v${VERSION}"
  SHA512 1b39c0faef74f29e0e709d54e4c8f3bf04adbfb601b4c5aa1199626abf1e0fa7681c2fe7dc7423da6852dcbd128efbadb7012ddccf3fa2868a09f934f656ac8d
  HEAD_REF main
)

file(COPY "${SOURCE_PATH}/napi.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/napi-inl.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/napi-inl.deprecated.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-node-addon-api-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
