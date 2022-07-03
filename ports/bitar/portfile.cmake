vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ljishen/bitar
  REF v0.0.4
  SHA512 172a198255100173b00a42feafd7f9b69e5dbd7b39983ffeda9f492ccabeb8a935c33ef9bc312d16cc3453ddcf59ff9dbbba1957f75064b900fb7f30e015a450
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
