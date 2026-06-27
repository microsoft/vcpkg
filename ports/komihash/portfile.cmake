# Header-only library
set(VCPKG_BUILD_TYPE "release")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO avaneev/komihash
  REF "${VERSION}"
  SHA512 ae8fc47fd58671aaff5fe75dc54e9a6d1d6e6b953290b507c94fffeede1425010fe20ba873ecbe8ed67e50217802604ee13bb29cbb208559725a2c54eaab06b7
  HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/komihash.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
