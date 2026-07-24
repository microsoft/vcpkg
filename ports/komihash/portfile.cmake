# Header-only library
set(VCPKG_BUILD_TYPE "release")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO avaneev/komihash
  REF "${VERSION}"
  SHA512 ea2f2a6dc3148ce8f49969c3164aa38c2830818a701346e497049806f7941261dfe1ccf5d59357dd777e91f60291894726fb31ac82dfdd285cca2faf2f11bae9
  HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/komihash.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
