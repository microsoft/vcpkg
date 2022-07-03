vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ljishen/bitar
  REF v0.0.4
  SHA512 1b4e645c3d51ba662faa2fca256edb89860f8eeab59d1d51a282ba1ae3a3c6fd497450ddc5c5db473f431651bfecf743d185230d4c4a51de97a0475333ea176b
  HEAD_REF main)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DVCPKG_ROOT=${VCPKG_ROOT_DIR}
    -DBITAR_FETCHCONTENT_OVERWRITE_CONFIGURATION=OFF)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
