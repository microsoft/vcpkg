# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uWebSockets
    REF "v${VERSION}"
    SHA512 49c0193e6b6dad5533f489b0a0247b5f5e3fa27b96e499699a42dcca2406a159b0158d11c4527bc7dd8da8b56427ff15eb08c28a660527ee76c1579366d3dd57
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/src" "${CURRENT_PACKAGES_DIR}/include/uwebsockets")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
