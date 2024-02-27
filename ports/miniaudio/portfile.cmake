# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mackron/miniaudio
  REF "${VERSION}"
  SHA512 b16fd9af65af050ddb0597498fc10aec1d277c9e6ebac968c0c2a0d8688181eb2a221f50b9d8101d454ede305ce50ab4c0729beaa1a6ffef71ab2402a7013994
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/miniaudio.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
