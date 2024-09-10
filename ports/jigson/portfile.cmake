vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO JoshuaSledden/Jigson
  REF "v${VERSION}"
  SHA512 e18e2cc2e625fd8263c7ae2c6c9d30464f8c4a41c7d731df58a406dd84caedf0c066e8ce2676bbaffb3abe6624820ed3fee4b0fef007bc277c810c496b00b2d3
)

file(GLOB HEADER_FILES "${SOURCE_PATH}/*.hpp" "${SOURCE_PATH}/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/jigson")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
