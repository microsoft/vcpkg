vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node-addon-api
  REF "v${VERSION}"
  SHA512 15e365f284c921e3d0464be645addae0b92b4500d4e58e4fd8a5b10aa7a79a49c9f4231bd61fb0982c2df3eb9d495d91e9961108bc92911413f0cffbec93d3a2
  HEAD_REF main
)

file(COPY "${SOURCE_PATH}/napi.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/napi-inl.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/napi-inl.deprecated.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-node-addon-api-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
