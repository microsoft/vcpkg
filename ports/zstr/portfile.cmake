set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mateidavid/zstr
  REF "v${VERSION}"
  SHA512 3f38761b9724fdcd8e3c1641cd37f0497fb6173a80817ac6c26a53853fd6673f39ca54893917b68b90036b6c86656853ada997851c2966a814ca2f01966a0524
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/strict_fstream.hpp"
     "${SOURCE_PATH}/src/zstr.hpp"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
