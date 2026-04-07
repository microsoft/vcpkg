vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO cbeck88/spirit-po
  REF v1.1.2
  SHA512 990e26e041607fe81cc2df673bd9e5e2647537d7e121b2300e631874dcd4ccdb084159fa4f635b128c39143c9423d67c494af05206b665541124a0447b8f4a3f
  HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/spirit_po
  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# spirit-po is header-only, so no vcpkg_{configure,install}_cmake

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spirit-po RENAME copyright)
