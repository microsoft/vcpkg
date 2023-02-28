vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node-addon-api
  REF v5.0.0
  SHA512 5ee14bc325ce66c6f645c3b638efaf69a7dfc90f0d6514f8568dedf34d5b5460b80c4438c4c12264d80c827edf46a82f0ecceb53b2a370ed5ec2ee640fa1ef7f
  HEAD_REF main
)

file(COPY "${SOURCE_PATH}/napi.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/napi-inl.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/napi-inl.deprecated.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-node-addon-api-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
