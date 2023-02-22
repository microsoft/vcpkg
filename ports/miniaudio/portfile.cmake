# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mackron/miniaudio
  REF a0dc1037f99a643ff5fad7272cd3d6461f2d63fa
  SHA512 396608d8326777adfffb50216322198b9f86d73c6a83c5886dc9eaef93b82a4e8f44f446192990b7b9fabac53fad073546214692a000415307e70812a50fb0c2
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/miniaudio.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
