vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/EGL-Registry
  REF 992aa3914f8fea801b1034c992db389911d9f3c3
  SHA512 75524ed23066e856f080f6551a6c7b6573d13ff7b4555594e2987e1e6a38ba13042d5037d56d656048e83c0b4ff002b5badacf9224516f9f5e521d4af653805a
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
