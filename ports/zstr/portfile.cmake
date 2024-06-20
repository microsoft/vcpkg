# header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mateidavid/zstr
  REF "v${VERSION}"
  SHA512 3017da244810a45f7111f76f8d0dd988e162f08eab28b7465cad4549d84200fc834975275daf9588d35c6125e6f167c1e2dd5ec18022dac1eceabdc24d24cffe
  HEAD_REF master
)

# Install source files
file(INSTALL "${SOURCE_PATH}/src/strict_fstream.hpp"
     "${SOURCE_PATH}/src/zstr.hpp"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Install usage
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
