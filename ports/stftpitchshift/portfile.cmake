vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO jurihock/stftPitchShift
  HEAD_REF main
  REF e25def2f6aad9db865aded9f0550fd1c7925188f
  SHA512 a7e9343ede83eb7d37a231e3db80659f8fa7c61c70811618c75a817fcc94902f5fa4582f81e4473a0e137f12c2eaf17025a057a7ef7c4b348451454e39b3fa2f
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DVCPKG=ON
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/stftpitchshift" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
