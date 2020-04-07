include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/EGL-Registry
  REF aa9b63f3ab18aee92c95786a2478156430f809e4
  SHA512 5ee7143c2cb46defbe1b2ecb0fabfb52fac2d9529b98c638dd4c04a312a62e7f7b3aee27d9749c92174ab967d533136b5881ce37ae9f2bee6685f52ffa8c8db6
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
