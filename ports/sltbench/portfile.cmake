vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ivafanas/sltbench
  REF 52c7c7852abc3159185eb79e699ad77fadfc35bd
  SHA512 0c66b51f5a950a09df47019775941554538bc3642788f61aaf8c5ec3644d5fef721391f73c3fddfd9529159f9b81c7d7ed76c7995a79f37adaf8d0ff55a99d4b
  HEAD_REF master)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}" WINDOWS_USE_MSBUILD)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
