#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO svgpp/rapidxml_ns
  REF 04674e33e3bbfeee05875a29a36734667c0f3cfd
  SHA512 ec0f7a23fa60457a481c7b3acf4c127c3bf898d23655d346aeafb304f74e798d632c83d676873f2c764d241de6dc4392cff8d6ce0ee509a4b74ee2233b01c008
  HEAD_REF master
)

# Handle copyright
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rapidxml-ns)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rapidxml-ns/license.txt ${CURRENT_PACKAGES_DIR}/share/rapidxml-ns/copyright)

# Copy the header files
file(INSTALL ${SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/rapidxml-ns FILES_MATCHING PATTERN "*.hpp")
