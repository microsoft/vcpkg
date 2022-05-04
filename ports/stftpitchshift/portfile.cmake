vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO jurihock/stftPitchShift
  HEAD_REF main
  REF 79f4ab9db8eeb793ac2e007b7d3ef46bf473a9b1
  SHA512 da23a9b2dc44636e32410f7f31f8db602a8ba8aa5613c847d8e193cf9d409239ac90864fcd6d77eb42aa36b923db80077885c6075beb557f35ff9a070a7fdaf4
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DVCPKG=ON
)

vcpkg_install_cmake()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/stftpitchshift" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
