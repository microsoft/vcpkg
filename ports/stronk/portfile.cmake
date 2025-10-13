vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO twig-energy/stronk
  REF 32add119ccd5a023c155344459321c8988ac98ca
  HEAD_REF main
  SHA512 1097b4f84b8fb795537165b7ab7201492e0c2606324d317b73c76b9b9a3837c2db48980dde792598c6f797e1842a0dba4748c72be4ada89a29c4e70691c93af9
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
