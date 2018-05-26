include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/spirit-po-1.1.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/cbeck88/spirit-po/archive/v1.1.2.zip"
    FILENAME "spirit-po-1.1.2.zip"
    SHA512 8a33126c199765b91e832c64e546f240d532858e051b217189778ad01ef584c67f0f4b2f9674cb7b4a877ec2a2b21b5eda35dc24a12da8eb7a7990bf63a4a774
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${SOURCE_PATH}/include/spirit_po
  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# spirit-po is header-only, so no vcpkg_{configure,install}_cmake

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spirit-po RENAME copyright)
