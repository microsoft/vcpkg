include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/EGL-Registry
  REF 11478904448bbdf5757b798c856a525aa2b351b1
  SHA512 f1e54810cb2948e9d8798d65507069bba4ee6534d719e792db11e36d600ef37e59a34262809d8b1e41160ae1e45a283fa322cd9d9a647985c48a6d7d6d1706ee
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
