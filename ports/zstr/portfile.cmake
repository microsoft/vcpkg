# header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mateidavid/zstr
  REF "v${VERSION}"
  SHA512 21778d2b07c30da4fb9ee35832f39b02c95e54478c6610e28cece98908c51bcee6aed0754ec3948b71aa1e671a3d15ff2b555369379dc4583048c76d2b8305e8
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
