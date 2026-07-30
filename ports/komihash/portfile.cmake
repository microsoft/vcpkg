# Header-only library
set(VCPKG_BUILD_TYPE "release")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO avaneev/komihash
  REF "${VERSION}"
  SHA512 62c282b470af97583eda30e6bdea296d4f8fb38521d508cf2b2de6fb79590e869c7b5fb650d955d4ca8f98f61a31256f6cc5c9f944b4f5ef9ed5f82cfc421d4f
  HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/komihash.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
