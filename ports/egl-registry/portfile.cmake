vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/EGL-Registry
  REF 3ae2b7c48690d2ce13cc6db3db02dfc0572be65e
  SHA512 c7b09ded4964fa427546bd345a29325105b79079b59642214dc8f04de113f42de2bc4272dbbbd4a801d92afc20297442fdfa12043a0900cf1e2b1cd83f260883
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
