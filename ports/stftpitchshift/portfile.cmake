vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO jurihock/stftPitchShift
  HEAD_REF main
  REF 14bb99d9e76cdf84be5a6433d0ebe6bc91f79977
  SHA512 c4b9d57dc9241b50d9df618cb7959e0d5bc2cdd1c73e0ebfe8427c07c502b9c2c2bd810ef6bc67e5bdab4acb140e5f27bc256dcb62ff373a4b7d529c7e468906
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DVCPKG=ON
)

vcpkg_install_cmake()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/stftpitchshift" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
