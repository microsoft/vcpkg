vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/EGL-Registry
  REF af97e2c27b49a090a335fc6ed5040c780ad9fec8
  SHA512 89f29608702cb85c5280a7d86ef2cd1c77ed746d4a2577ea143767828ea41ef28cf038d2d86fe1eccc03db08ad27258cb04dadb92233ed9acc10548d93537a80
  HEAD_REF master
)

file(
  COPY
    "${SOURCE_PATH}/api/KHR"
    "${SOURCE_PATH}/api/EGL"
  DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

file(
  COPY
    "${SOURCE_PATH}/api/egl.xml"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/opengl"
)

file(
  INSTALL "${SOURCE_PATH}/sdk/docs/man/copyright.xml"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright
)

