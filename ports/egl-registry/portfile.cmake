include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/EGL-Registry
  REF 598f20e3b7b7eec3e8d8a83e64b9592a21c55bb6
  SHA512 360aa2399fec12ad23c5e4bce7e9287a9b1b1d98ba6c326dde2b1bc1c32735bc6933ca8e5c626ba421cda5aac216bc7c268e064cf0dd67605a23151e29ba1f36
  HEAD_REF master
)

file(
  COPY
    ${SOURCE_PATH}/api/KHR
    ${SOURCE_PATH}/api/EGL
  DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(
  COPY
    ${SOURCE_PATH}/api/egl.xml
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/egl-registry
)

file(
  INSTALL ${SOURCE_PATH}/sdk/docs/man/copyright.xml
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/egl-registry
  RENAME copyright
)
