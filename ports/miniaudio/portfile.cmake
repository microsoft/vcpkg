# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mackron/miniaudio
  REF "${VERSION}"
  SHA512 b12566432e0167082dd9ad5b5c5fc3d80a80c7803016a59c670f5fb3436c2db8b16411e3f10571eafbf6791c53b761c3deeabb22b6329f80bbe891c760365c3c
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/miniaudio.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
