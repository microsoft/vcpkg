vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/EGL-Registry
  REF 7db3005d4c2cb439f129a0adc931f3274f9019e6
  SHA512 474d7a4d614efed18151e0ff18840aaa8349ec0b01ec3cc4e6ff3f60fdb918e0b8c68dbb13e09dc5e7b081a9eb637b008b48b1a4be537d360f9a6d247b7b8802
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

vcpkg_install_copyright(FILE_LIST "${CURRENT_PORT_DIR}/copyright")
