# Header-only library
set(VCPKG_BUILD_TYPE "release")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO avaneev/komihash
  REF "${VERSION}"
  SHA512 ebd683757ebde616bb68f45aaed95a7a67724e6d5306f01246165fffdb7c7b4114a5674bdd08449cf69093d17834fbb298c7e87292e27f2df7be32c754835a24
  HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/komihash.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
