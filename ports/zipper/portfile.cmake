vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sebastiandev/zipper
  REF 155e17347b64f7182985a2772ebb179184e4f518
  SHA512 91ec37bf230d3f636fce60316281c5314c0b41764397b1a45bc22c30e4178f6bc95400c361dc72ea0611949456879dfb43e53827d4e2b006a4677e16d2284ed0
  HEAD_REF master
)


vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME zipper)
