vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO JoshuaSledden/Jigson
  REF "v${VERSION}"
  SHA512 1f2d7169f7b534446d053b8faa0c4b0e47f4b85714256c2865d36d557150d799acd553ed4e41db791fc55c0f63b533dc04d351deb1c3b8a5c8fe768bb71908e1
)

file(GLOB HEADER_FILES "${SOURCE_PATH}/*.hpp" "${SOURCE_PATH}/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/jigson")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
