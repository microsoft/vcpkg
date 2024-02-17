# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uWebSockets
    REF "v${VERSION}"
    SHA512 84dd2f318fce8d66e856152f25e4e682c43dddbaadf00e083628bd9ca16bc3e4b22e01058b89c9b294cdb0d99ab725b37cc69340836f9e20a3a5442b71082ef4
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/src" "${CURRENT_PACKAGES_DIR}/include/uwebsockets")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
