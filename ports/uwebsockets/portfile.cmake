# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uWebSockets
    REF "v${VERSION}"
    SHA512 c686eaffd18a925661f2b3fbae108bdd227dc5e87981bf494e3299a9b7d8dbee2838b53eefc05d20eb9669643882dc0de4fdd6f1f57d1a878107bbe69aba6fa5
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/src" "${CURRENT_PACKAGES_DIR}/include/uwebsockets")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
