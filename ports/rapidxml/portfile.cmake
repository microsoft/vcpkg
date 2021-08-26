#header-only library
vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rapidxml/rapidxml
    REF rapidxml%201.13
    FILENAME "rapidxml-1.13.zip"
    SHA512 6c10583e6631ccdb0217d0a5381172cb4c1046226de6ef1acf398d85e81d145228e14c3016aefcd7b70a1db8631505b048d8b4f5d4b0dbf1811d2482eefdd265
)

# Handle copyright
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rapidxml)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rapidxml/license.txt ${CURRENT_PACKAGES_DIR}/share/rapidxml/copyright)

# Copy the header files
file(INSTALL ${SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/rapidxml FILES_MATCHING PATTERN "*.hpp")
