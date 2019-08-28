include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/EGL-Registry
  REF e2562a9e7f567b837cdf96cf8b12e7fc0d88cc30
  SHA512 8c380c26f6afc0ce2ab2dd2fe834daae0d0dbe9e2bd55ab30c80f8dfa5e234f1902e5735c4d8acf016f03924a46431b9bb794bb77f1f091c56905a98c38f5d04
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
