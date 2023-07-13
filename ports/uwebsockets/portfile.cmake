# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uWebSockets
    REF "v${VERSION}"
    SHA512 ceb950a3d4c2ffd58867ef1cc92d5405441dff603ceb6958ef5660f93c8e1da2346cecb43d209ab08d4feac9c1f023f7bff22a13f537dbb3eab0f122f27f70f6
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/src" "${CURRENT_PACKAGES_DIR}/include/uwebsockets")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
