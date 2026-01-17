# Header-only library
set(VCPKG_BUILD_TYPE "release")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO avaneev/komihash
  REF "${VERSION}"
  SHA512 c1d70748d4efd887d4f5ad1482044158322d72485e30eab387e8dc3d4a7c8ca6296035afb8003ed86991003d3550990e6fe486236c70594d1dcdcc39e77dc438
  HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/komihash.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
